resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  description = "Cloudwatch agent config to configure custom log"
  name        = "/cloudwatch-agent/config"
  type        = "String"
  value = templatefile("amazon-cloudwatch-agent.json", {
    application_log_directory = var.application_log_directory
    application_log_file_name = var.application_log_file_name
    project_id                = var.project_id
  })
}

resource "aws_ssm_parameter" "db_init_script" {
  description = "Script to setup the DB and role"
  name        = format("/config/%s/db-init-script", var.project_id)
  type        = "String"
  value = templatefile("db_init.sql", {
    db_name     = var.rds_psql_application_db_name
    db_role     = var.rds_psql_application_role
    db_password = var.rds_psql_application_password
    db_schema   = var.rds_psql_application_schema
  })
}

resource "aws_ssm_parameter" "application_jdbc_url" {
  description = "The username that the application uses to connect to the DB"
  name        = format("/config/%s/spring.datasource.url", var.project_id)
  type        = "SecureString"
  value       = format("jdbc:postgresql://%s:%s/%s?currentSchema=%s", data.aws_db_instance.database.host, data.aws_db_instance.database.port, var.rds_psql_application_db_name, var.rds_psql_application_schema)
}

resource "aws_ssm_parameter" "application_db_username" {
  description = "The password that the application uses to connect to the DB"
  name        = format("/%s/db/spring.datasource.username", var.project_id)
  type        = "SecureString"
  value       = var.rds_psql_application_role
}

resource "aws_ssm_parameter" "application_db_password" {
  description = "The host of the DB that the application connects to"
  name        = format("/%s/db/spring.datasource.password", var.project_id)
  type        = "SecureString"
  value       = var.rds_psql_application_password
}
