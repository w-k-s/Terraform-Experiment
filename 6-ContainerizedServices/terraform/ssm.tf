resource "aws_ssm_parameter" "application_jdbc_url" {
  description = "The username that the application uses to connect to the DB"
  name        = format("/config/%s/spring.datasource.url", var.project_id)
  type        = "SecureString"
  value       = format("jdbc:postgresql://%s/%s?currentSchema=%s", data.aws_db_instance.database.endpoint, var.rds_psql_application_db_name, var.rds_psql_application_schema)
}

resource "aws_ssm_parameter" "application_db_username" {
  description = "The password that the application uses to connect to the DB"
  name        = format("/config/%s/spring.datasource.username", var.project_id)
  type        = "SecureString"
  value       = var.rds_psql_application_role
}

resource "aws_ssm_parameter" "application_db_password" {
  description = "The host of the DB that the application connects to"
  name        = format("/config/%s/spring.datasource.password", var.project_id)
  type        = "SecureString"
  value       = var.rds_psql_application_password
}

resource "aws_ssm_parameter" "tasks_sqs_queue_name" {
  description = "The name of the messaging queue on which task events are published"
  name        = format("/config/%s/messaging.queue.tasks.name", var.project_id)
  type        = "SecureString"
  value       = aws_sqs_queue.tasks.name
}
