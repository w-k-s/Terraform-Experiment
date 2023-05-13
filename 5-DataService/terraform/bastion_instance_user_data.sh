#!/bin/bash
# Update package list and upgrade installed packages
sudo apt-get update
sudo apt-get upgrade -y

# Install Postgres and other dependencies
sudo apt-get install awscli -y
sudo apt-get install postgresql -y

# Download the psql script from Parameter Store
aws ssm get-parameter --name ${db_init_script_ssm_param_name} --query "Parameter.Value" --output text --region ${aws_region} > /home/ubuntu/psql_script.sql

export PGPASSWORD=${rds_psql_master_password};
if pg_isready -d {db_name} -h ${db_address} -p ${db_port} -U ${rds_psql_master_username} >/dev/null 2>&1; then
  echo "PostgreSQL server is up and running"
else
  psql "host=${db_address} port=${db_port} dbname=postgres user=${rds_psql_master_username} password=${rds_psql_master_password}" -f psql_script.sql
fi