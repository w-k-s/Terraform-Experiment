# Connect to an existing RDS instance
data "aws_db_instance" "database" {
  db_instance_identifier = var.rds_psql_instance_identifier
}

# resource "null_resource" "db_setup" {
#   triggers = {
#     sql_script_content = local_file.sql_script.content
#   }

#   provisioner "local-exec" {

#     command = "psql -h ${aws_db_instance.database.endpoint} -p 5432 -U \"${var.rds_psql_master_username}\" -d postgres -f \"path-to-file-with-sql-commands\""

#     environment = {
#       PGPASSWORD = "${var.rds_psql_master_password}"
#     }
#   }
# }
