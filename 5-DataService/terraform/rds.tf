# Connect to an existing RDS instance
data "aws_db_instance" "database" {
  db_instance_identifier = var.rds_psql_instance_identifier
}

provider "postgresql" {
  scheme    = "awspostgres"
  host      = aws_db_instance.database.address
  username  = var.rds_psql_master_username
  port      = aws_db_instance.database.port
  password  = var.rds_psql_master_password
  superuser = false
}

resource "random_password" "db_default" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "postgresql_role" "application_role" {
  name     = var.rds_psql_application_role
  login    = true
  password = var.rds_psql_application_password == "" ? random_password.db_default : var.rds_psql_application_password
}

resource "postgresql_database" "application_db" {
  name              = var.rds_psql_application_db_name
  owner             = "DEFAULT"
  encoding          = "UTF8"
  connection_limit  = 10
  allow_connections = true
}

resource "postgresql_grant" "application_privielegs" {
  database    = var.rds_psql_application_db_name
  role        = var.rds_psql_application_role
  schema      = var.rds_psql_application_schema
  object_type = "schema"
  privileges = [
    "CONNECT",    # Allows the grantee to connect to the database
    "INSERT",     # Allows INSERT of a new row into a table (within schema)
    "SELECT",     # Allows SELECT from any column, or specific column(s), of a table, view, materialized view, or other table-like object.
    "UPDATE",     # Allows UPDATE of any column, or specific column(s), of a table, view
    "DELETE",     # Allows DELETE of a row from a table
    "EXECUTE",    # Allows calling a function or procedure
    "CREATE",     # Allows new objects to be created within the schema. If you can create, you can alter and drop.
    "REFERENCES", # Allows creation of a foreign key constraint referencing a table, or specific column(s) of a table.
    "TRIGGER",    # Allows creation of a trigger on a table, view, etc.
    "USAGE",      # Allows executing functions
  ]
}
