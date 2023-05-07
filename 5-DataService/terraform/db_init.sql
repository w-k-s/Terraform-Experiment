-- Create the noticeboard database if it doesn't exist
CREATE DATABASE IF NOT EXISTS ${db_name};

-- Connect to the noticeboard database
\c ${db_name};

-- Create the noticeboard schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS ${db_schema};

-- Create the noticeboarduser role if it doesn't exist
CREATE ROLE IF NOT EXISTS ${db_role};

-- Set the password for the noticeboarduser role
ALTER ROLE ${db_role} WITH PASSWORD '${db_password}';

-- Grant all privileges on all tables in the noticeboard schema to the noticeboarduser role
GRANT CONNECT ON DATABASE ${db_name} TO ${db_role};
GRANT USAGE, SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ${db_schema} TO ${db_role};
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA ${db_schema} TO ${db_role};