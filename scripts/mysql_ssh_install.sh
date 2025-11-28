#!/usr/bin/env bash
# push-and-import.sh
# Usage: ./push-and-import.sh
# Fill variables below or export them beforehand.

set -euo pipefail
IFS=$'\n\t'

########## CONFIGURE BELOW ##########
# Local path to your SQL dump
LOCAL_DUMP="ecommerce_dump.sql"

# Remote server SSH info
REMOTE_USER="ec2-user"            # e.g. ec2-user, ubuntu, centos
REMOTE_HOST="54.175.214.236"             # server IP or hostname
REMOTE_SSH_KEY="~/aws_keys.pem"                 # optional: path to private key, e.g. ~/.ssh/id_rsa ; leave empty to use default agent/ssh keys
REMOTE_DIR="/home/ec2-user"                 # remote dir where dump will be copied

# RDS / MySQL target (the script will run the mysql client on the remote server to connect to RDS)
RDS_HOST="prod-rds-instance.ce9u8gyqms1d.us-east-1.rds.amazonaws.com"
RDS_PORT="3306"
RDS_USER="admin"
RDS_DB="ecommerce"

# Whether to install the mysql server (true/false)
INSTALL_MYSQL_SERVER=true
########## END CONFIG ##########

# helper to build scp/ssh flags
SSH_OPTS=()
if [[ -n "$REMOTE_SSH_KEY" ]]; then
  SSH_OPTS+=(-i "$REMOTE_SSH_KEY")
fi
# avoid known_hosts prompts (optional; remove if you prefer strict host checks)
SSH_OPTS+=(-o StrictHostKeyChecking=accept-new)

SCP_OPTS=("${SSH_OPTS[@]}")

# sanity checks
if [[ ! -f "$LOCAL_DUMP" ]]; then
  echo "ERROR: local dump file not found: $LOCAL_DUMP"
  exit 2
fi

# Ask for RDS password (hidden)
read -rsp "RDS password for user '$RDS_USER': " RDS_PASSWORD
echo

# Ensure REMOTE_DIR is set to a valid directory with write permissions
if [[ -z "$REMOTE_DIR" ]]; then
  REMOTE_DIR="/home/$REMOTE_USER"
  echo "REMOTE_DIR was empty, defaulting to $REMOTE_DIR"
fi

REMOTE_FILE="$REMOTE_DIR/$(basename "$LOCAL_DUMP")"

echo "Copying local dump '$LOCAL_DUMP' -> ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_FILE}"
scp "${SCP_OPTS[@]}" "$LOCAL_DUMP" "${REMOTE_USER}@${REMOTE_HOST}:$REMOTE_FILE"

echo "Running remote installation and import commands on ${REMOTE_HOST}..."

# Build remote commands to execute (quoted so variables expand remotely)
read -r -d '' REMOTE_COMMANDS <<'EOF' || true
set -euo pipefail

REMOTE_FILE="$REMOTE_FILE"   # replaced by caller via env
RDS_HOST="$RDS_HOST"
RDS_PORT="$RDS_PORT"
RDS_USER="$RDS_USER"
RDS_DB="$RDS_DB"
RDS_PASSWORD="$RDS_PASSWORD"
INSTALL_MYSQL_SERVER="$INSTALL_MYSQL_SERVER"

echo "Updating and installing requirements..."
# download repository rpm
sudo wget -q https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm -O /tmp/mysql80-community-release-el9-1.noarch.rpm

# install the release package (adds MySQL repo)
sudo dnf install -y /tmp/mysql80-community-release-el9-1.noarch.rpm

# import GPG key (safe to re-run)
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023

# install client (and server if requested)
sudo dnf install -y mysql-community-client

if [ "$INSTALL_MYSQL_SERVER" = "true" ] || [ "$INSTALL_MYSQL_SERVER" = "True" ] || [ "$INSTALL_MYSQL_SERVER" = "1" ]; then
  sudo dnf install -y mysql-community-server
  # enable & start server (optional)
  sudo systemctl enable --now mysqld || true
fi

echo "Importing dump to RDS ($RDS_HOST:$RDS_PORT / db: $RDS_DB) using mysql client..."
# make sure file exists
if [ ! -f "$REMOTE_FILE" ]; then
  echo "ERROR: remote dump not found: $REMOTE_FILE" >&2
  exit 3
fi

# Using MYSQL_PWD env var to avoid interactive prompt.
# Note: this exposes password to the process environment briefly on the server.
# If you prefer interactive, remove MYSQL_PWD and use -p to be prompted.
export MYSQL_PWD="$RDS_PASSWORD"

# Import (input redirection)
mysql -h "$RDS_HOST" -P "$RDS_PORT" -u "$RDS_USER" "$RDS_DB" < "$REMOTE_FILE"

# cleanup (optional)
# rm -f "$REMOTE_FILE"

echo "Import finished."
EOF

# We need to pass many variables into the remote session. We'll send them in the environment via ssh -o SendEnv is not reliable by default,
# so we'll wrap them in a heredoc that defines them before running the commands.
# Replace the placeholder variables in the REMOTE_COMMANDS block with actual values safely using env substitution.
# To avoid accidental expansion locally, we used 'EOF' quoting; now produce a final remote script replacing placeholders.
TMP_REMOTE_SCRIPT=$(mktemp)
cat > "$TMP_REMOTE_SCRIPT" <<EOF
#!/bin/bash
set -euo pipefail
REMOTE_FILE="$REMOTE_FILE"
RDS_HOST="$RDS_HOST"
RDS_PORT="$RDS_PORT"
RDS_USER="$RDS_USER"
RDS_DB="$RDS_DB"
RDS_PASSWORD="$RDS_PASSWORD"
INSTALL_MYSQL_SERVER="${INSTALL_MYSQL_SERVER}"
EOF

# Append the actual commands to the script
cat >> "$TMP_REMOTE_SCRIPT" <<'INNER'
# the rest of the commands:
echo "Updating and installing requirements..."
sudo wget -q https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm -O /tmp/mysql80-community-release-el9-1.noarch.rpm
sudo dnf install -y /tmp/mysql80-community-release-el9-1.noarch.rpm
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
sudo dnf install -y mysql-community-client
if [ "$INSTALL_MYSQL_SERVER" = "true" ] || [ "$INSTALL_MYSQL_SERVER" = "True" ] || [ "$INSTALL_MYSQL_SERVER" = "1" ]; then
  sudo dnf install -y mysql-community-server
  sudo systemctl enable --now mysqld || true
fi
echo "Importing dump to RDS (${RDS_HOST}:${RDS_PORT} / db: ${RDS_DB}) using mysql client..."
echo "Looking for dump file at: ${REMOTE_FILE}"
ls -la "${REMOTE_FILE}" || echo "File not found with ls"
if [ ! -f "${REMOTE_FILE}" ]; then
  echo "ERROR: remote dump not found: ${REMOTE_FILE}" >&2
  exit 3
fi
export MYSQL_PWD="${RDS_PASSWORD}"
mysql -h "${RDS_HOST}" -P "${RDS_PORT}" -u "${RDS_USER}" "${RDS_DB}" < "${REMOTE_FILE}"
echo "Import finished."
INNER

# copy the remote script and execute it
REMOTE_SCRIPT_PATH="/tmp/remote_import_$$.sh"
scp "${SCP_OPTS[@]}" "$TMP_REMOTE_SCRIPT" "${REMOTE_USER}@${REMOTE_HOST}:$REMOTE_SCRIPT_PATH"
ssh "${SSH_OPTS[@]}" "${REMOTE_USER}@${REMOTE_HOST}" "chmod +x $REMOTE_SCRIPT_PATH && $REMOTE_SCRIPT_PATH"

# cleanup local temp script
rm -f "$TMP_REMOTE_SCRIPT"

echo "All done."
