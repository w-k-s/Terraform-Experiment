resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  description = "Cloudwatch agent config to configure custom log"
  name        = "/cloudwatch-agent/config"
  type        = "String"
  value = templatefile("amazon-cloudwatch-agent.json", {
    application_log_directory = var.application_log_directory
    application_log_file_name = var.application_log_file_name
    project_name              = var.log_group_name
  })
}

resource "aws_ssm_parameter" "cognito_client_id" {
  description = "Cognito Client ID"
  name        = format("/%s/oauth2/client_id", var.log_group_name)
  type        = "String"
  value       = aws_cognito_user_pool_client.this.id
}

resource "aws_ssm_parameter" "cognito_client_secret" {
  description = "Cognito Client ID"
  name        = format("/%s/oauth2/client_secret", var.log_group_name)
  type        = "SecureString"
  value       = aws_cognito_user_pool_client.this.client_secret
}

resource "aws_ssm_parameter" "application_db_username" {
  description = "The username that the application uses to connect to the DB"
  name        = format("/%s/db/username", var.log_group_name)
  type        = "SecureString"
  value       = var.rds_psql_application_role
}

resource "aws_ssm_parameter" "application_db_password" {
  description = "The password that the application uses to connect to the DB"
  name        = format("/%s/db/password", var.log_group_name)
  type        = "SecureString"
  value       = var.rds_psql_application_password
}

resource "aws_ssm_parameter" "application_db_host" {
  description = "The host of the DB that the application connects to"
  name        = format("/%s/db/host", var.log_group_name)
  type        = "String"
  value       = aws_db_instance.database.address
}

resource "aws_ssm_parameter" "application_db_port" {
  description = "The port of the DB that the application connects to"
  name        = format("/%s/db/port", var.log_group_name)
  type        = "String"
  value       = aws_db_instance.database.port
}

resource "aws_ssm_parameter" "application_db_port" {
  description = "The schema of the DB that the application connects to"
  name        = format("/%s/db/schema", var.log_group_name)
  type        = "String"
  value       = var.rds_psql_application_schema
}