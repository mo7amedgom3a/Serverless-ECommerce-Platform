# Ansible Automation for MySQL RDS Setup

This Ansible project automates the installation of MySQL client on Amazon Linux EC2 instances and imports SQL database dumps to Amazon RDS.

## Features

- ✅ Installs MySQL 8.0 client on Amazon Linux
- ✅ Optionally installs MySQL server
- ✅ Copies SQL dump files from local machine to EC2
- ✅ Imports SQL dumps to Amazon RDS
- ✅ Parameterized configuration via variables
- ✅ Secure credential management with Ansible Vault
- ✅ Idempotent and reusable roles

## Prerequisites

### Local Machine

- Ansible 2.9+ installed
- SSH access to EC2 instance
- SSH private key for EC2 instance

### EC2 Instance

- Amazon Linux 2023 or Amazon Linux 2
- Python 3 installed
- Sudo privileges for ec2-user
- Network access to RDS instance

### RDS Instance

- MySQL-compatible RDS instance running
- Security group allowing connections from EC2
- Database credentials

## Project Structure

```
ansible/
├── ansible.cfg                          # Ansible configuration
├── inventory/
│   ├── hosts.yml                       # EC2 instance inventory
│   └── group_vars/
│       └── all.yml                     # Global variables
├── playbooks/
│   └── setup_mysql_rds.yml            # Main playbook
├── roles/
│   ├── mysql_client/                   # MySQL client installation
│   │   ├── tasks/main.yml
│   │   └── defaults/main.yml
│   └── rds_import/                     # RDS database import
│       ├── tasks/main.yml
│       └── defaults/main.yml
└── vars/
    └── rds_credentials.yml             # RDS credentials (encrypted)
```

## Quick Start

### 1. Configure Variables

#### Edit `inventory/group_vars/all.yml`:

```yaml
ec2_public_ip: "54.175.214.236" # Your EC2 public IP
ssh_key_path: "~/.ssh/aws_keys.pem" # Path to your SSH key
```

#### Edit `vars/rds_credentials.yml`:

```yaml
rds_host: "your-rds-instance.region.rds.amazonaws.com"
rds_port: 3306
rds_user: "admin"
rds_password: "your-secure-password"
rds_database: "ecommerce"
```

### 2. Encrypt Credentials (Recommended)

```bash
cd ansible
ansible-vault encrypt vars/rds_credentials.yml
# Enter a vault password when prompted
```

To edit encrypted file later:

```bash
ansible-vault edit vars/rds_credentials.yml
```

### 3. Run the Playbook

#### Without vault:

```bash
ansible-playbook playbooks/setup_mysql_rds.yml
```

#### With vault:

```bash
ansible-playbook playbooks/setup_mysql_rds.yml --ask-vault-pass
```

## Usage Examples

### Basic Usage

```bash
ansible-playbook playbooks/setup_mysql_rds.yml
```

### Override Variables via Command Line

```bash
ansible-playbook playbooks/setup_mysql_rds.yml \
  -e "ec2_public_ip=54.175.214.236" \
  -e "rds_host=my-rds.amazonaws.com" \
  -e "rds_database=mydb"
```

### Run Only Specific Tags

```bash
# Install MySQL client only
ansible-playbook playbooks/setup_mysql_rds.yml --tags mysql

# Import database only (assumes MySQL client already installed)
ansible-playbook playbooks/setup_mysql_rds.yml --tags import
```

### Dry Run (Check Mode)

```bash
ansible-playbook playbooks/setup_mysql_rds.yml --check
```

### Verbose Output

```bash
ansible-playbook playbooks/setup_mysql_rds.yml -v   # verbose
ansible-playbook playbooks/setup_mysql_rds.yml -vv  # more verbose
ansible-playbook playbooks/setup_mysql_rds.yml -vvv # debug
```

## Configuration Variables

### Global Variables (`inventory/group_vars/all.yml`)

| Variable                    | Description                            | Default                         |
| --------------------------- | -------------------------------------- | ------------------------------- |
| `ec2_public_ip`             | EC2 instance public IP                 | `CHANGE_ME`                     |
| `ssh_key_path`              | Path to SSH private key                | `~/.ssh/aws_keys.pem`           |
| `install_mysql_server`      | Install MySQL server (not just client) | `false`                         |
| `sql_dump_local_path`       | Local path to SQL dump file            | `../scripts/ecommerce_dump.sql` |
| `sql_dump_remote_path`      | Remote path on EC2                     | `/tmp/ecommerce_dump.sql`       |
| `cleanup_dump_after_import` | Remove dump after import               | `true`                          |

### RDS Credentials (`vars/rds_credentials.yml`)

| Variable       | Description           | Example                                |
| -------------- | --------------------- | -------------------------------------- |
| `rds_host`     | RDS instance endpoint | `prod-rds.us-east-1.rds.amazonaws.com` |
| `rds_port`     | MySQL port            | `3306`                                 |
| `rds_user`     | Database username     | `admin`                                |
| `rds_password` | Database password     | `SecurePassword123!`                   |
| `rds_database` | Database name         | `ecommerce`                            |

## Roles

### mysql_client

Installs MySQL 8.0 client (and optionally server) on Amazon Linux.

**Tasks:**

1. Download MySQL repository RPM
2. Install MySQL repository
3. Import GPG key
4. Install MySQL client
5. Optionally install MySQL server
6. Verify installation

### rds_import

Copies SQL dump file and imports it to RDS.

**Tasks:**

1. Verify local SQL dump exists
2. Copy dump to EC2 instance
3. Test RDS connection
4. Import dump to RDS
5. Verify import (show tables)
6. Clean up dump file

## Security Best Practices

### 1. Use Ansible Vault for Credentials

```bash
# Encrypt credentials file
ansible-vault encrypt vars/rds_credentials.yml

# Use vault password file
echo "my-vault-password" > ~/.vault_pass
chmod 600 ~/.vault_pass
ansible-playbook playbooks/setup_mysql_rds.yml --vault-password-file ~/.vault_pass
```

### 2. Restrict SSH Key Permissions

```bash
chmod 600 ~/.ssh/aws_keys.pem
```

### 3. Use IAM Authentication (Advanced)

For production, consider using IAM database authentication instead of passwords.

## Troubleshooting

### Connection Issues

**Problem:** Cannot connect to EC2

```bash
# Test SSH connection manually
ssh -i ~/.ssh/aws_keys.pem ec2-user@54.175.214.236

# Check inventory
ansible-inventory --list -i inventory/hosts.yml

# Test Ansible connection
ansible rds_admin_servers -m ping
```

**Problem:** Cannot connect to RDS

```bash
# Test from EC2 instance
ssh -i ~/.ssh/aws_keys.pem ec2-user@54.175.214.236
mysql -h your-rds.amazonaws.com -u admin -p

# Check security groups
# Ensure EC2 security group is allowed in RDS security group
```

### MySQL Installation Issues

**Problem:** GPG key import fails

```bash
# Manually import key on EC2
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
```

**Problem:** Package conflicts

```bash
# Remove conflicting packages
sudo dnf remove mariadb-libs
```

### Import Issues

**Problem:** SQL dump file not found

```bash
# Verify local file exists
ls -la ../scripts/ecommerce_dump.sql

# Check variable
ansible-playbook playbooks/setup_mysql_rds.yml -e "sql_dump_local_path=/full/path/to/dump.sql"
```

**Problem:** Import fails with permissions error

```bash
# Ensure RDS user has proper privileges
# Connect to RDS and run:
GRANT ALL PRIVILEGES ON ecommerce.* TO 'admin'@'%';
FLUSH PRIVILEGES;
```

## Advanced Usage

### Multiple Environments

Create separate variable files for different environments:

```bash
# vars/dev_rds.yml
# vars/staging_rds.yml
# vars/prod_rds.yml

# Run with specific environment
ansible-playbook playbooks/setup_mysql_rds.yml \
  -e @vars/dev_rds.yml
```

### Multiple EC2 Instances

Add more hosts to `inventory/hosts.yml`:

```yaml
all:
  children:
    rds_admin_servers:
      hosts:
        ec2_rds_admin_1:
          ansible_host: "54.175.214.236"
        ec2_rds_admin_2:
          ansible_host: "54.175.214.237"
```

### Custom SQL Dumps

```bash
ansible-playbook playbooks/setup_mysql_rds.yml \
  -e "sql_dump_local_path=/path/to/custom_dump.sql"
```

## Comparison with Shell Script

| Feature        | Shell Script  | Ansible             |
| -------------- | ------------- | ------------------- |
| Idempotency    | ❌ No         | ✅ Yes              |
| Multi-host     | ❌ Manual     | ✅ Automatic        |
| Error handling | ⚠️ Basic      | ✅ Advanced         |
| Reusability    | ⚠️ Limited    | ✅ High (roles)     |
| Readability    | ⚠️ Procedural | ✅ Declarative      |
| Testing        | ❌ No dry-run | ✅ Check mode       |
| Credentials    | ⚠️ Plain text | ✅ Vault encryption |

## Contributing

To extend this automation:

1. Add new roles in `roles/` directory
2. Update playbook to include new roles
3. Document new variables in this README
4. Test with `--check` mode first

## License

This project is part of the Serverless E-Commerce Platform.

## Support

For issues or questions, please refer to the main project documentation.
