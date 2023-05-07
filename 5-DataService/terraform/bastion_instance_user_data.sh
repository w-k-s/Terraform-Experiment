#!/bin/bash
# Update package list and upgrade installed packages
sudo apt-get update
sudo apt-get upgrade -y

# Install Postgres and other dependencies
sudo apt-get install awscli -y
sudo apt-get install postgresql -y

# Download the psql script from Parameter Store
aws ssm get-parameter --name ${db_init_script_ssm_param_name} --query "Parameter.Value" --output text > /home/ubuntu/psql_script.sql

# Connect to the Postgres server and execute the script
sudo -u postgres psql -f /home/ubuntu/psql_script.sql