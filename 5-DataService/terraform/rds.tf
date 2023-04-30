# Connect to an existing RDS instance
data "aws_db_instance" "database" {
  db_instance_identifier = var.rds_psql_instance_identifier
}
