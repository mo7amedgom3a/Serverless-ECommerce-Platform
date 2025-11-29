#!/bin/bash
# Example script to run the Ansible playbook
# Usage: ./run_playbook.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}MySQL RDS Setup - Ansible Playbook${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if Ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${RED}Error: Ansible is not installed${NC}"
    echo "Please install Ansible: pip install ansible"
    exit 1
fi

# Check if required files exist
if [ ! -f "playbooks/setup_mysql_rds.yml" ]; then
    echo -e "${RED}Error: Playbook not found${NC}"
    echo "Make sure you're running this from the ansible/ directory"
    exit 1
fi

# Check if variables are configured
if grep -q "CHANGE_ME" inventory/group_vars/all.yml; then
    echo -e "${YELLOW}Warning: Please configure inventory/group_vars/all.yml${NC}"
    echo "Set your EC2 public IP and other variables"
    exit 1
fi

# Ask if user wants to use vault
echo -e "${YELLOW}Do you want to use Ansible Vault for credentials? (y/n)${NC}"
read -r use_vault
export ANSIBLE_CONFIG=/mnt/sda2/repos/Serverless-ECommerce-Platform/ansible/ansible.cfg

if [ "$use_vault" = "y" ] || [ "$use_vault" = "Y" ]; then
    # Check if vault file is encrypted
    if head -n 1 vars/rds_credentials.yml | grep -q "ANSIBLE_VAULT"; then
        echo -e "${GREEN}Running playbook with vault...${NC}"
        ansible-playbook playbooks/setup_mysql_rds.yml --ask-vault-pass
    else
        echo -e "${YELLOW}Vault file is not encrypted. Encrypt it first:${NC}"
        echo "ansible-vault encrypt vars/rds_credentials.yml"
        exit 1
    fi
else
    echo -e "${GREEN}Running playbook without vault...${NC}"
    ansible-playbook playbooks/setup_mysql_rds.yml
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Playbook execution completed!${NC}"
echo -e "${GREEN}========================================${NC}"
