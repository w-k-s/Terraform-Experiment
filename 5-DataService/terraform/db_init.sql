-- Create the noticeboard database if it doesn't exist
CREATE DATABASE ${db_name};

-- Connect to the noticeboard database
\c ${db_name};

-- Create the noticeboard schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS ${db_schema};

-- Create the noticeboarduser role if it doesn't exist
CREATE ROLE ${db_role};

-- Set the password for the noticeboarduser role
ALTER ROLE ${db_role} WITH LOGIN PASSWORD '${db_password}';

-- Grant all privileges on all tables in the noticeboard schema to the noticeboarduser role
-- The terraform script works but these terraform scrips are a no go.
GRANT CONNECT ON DATABASE ${db_name} TO ${db_role};
GRANT ALL PRIVILEGES ON SCHEMA ${db_schema} TO ${db_role};