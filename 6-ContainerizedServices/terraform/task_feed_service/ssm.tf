resource "aws_ssm_parameter" "application_jdbc_url" {
  description = "The username that the application uses to connect to the DB"
  name        = format("/config/%s/spring.datasource.url", var.paramstore_name)
  type        = "SecureString"
  value       = format("jdbc:postgresql://%s/%s?currentSchema=%s", var.db_endpoint, var.db_name, var.db_schema)
}

resource "aws_ssm_parameter" "application_db_username" {
  description = "The password that the application uses to connect to the DB"
  name        = format("/config/%s/spring.datasource.username", var.paramstore_name)
  type        = "SecureString"
  value       = var.db_username
}

resource "aws_ssm_parameter" "application_db_password" {
  description = "The host of the DB that the application connects to"
  name        = format("/config/%s/spring.datasource.password", var.paramstore_name)
  type        = "SecureString"
  value       = var.db_password
}

resource "aws_ssm_parameter" "tasks_sqs_queue_name" {
  description = "The name of the messaging queue on which task events are published"
  name        = format("/config/%s/messaging.queue.tasks.name", var.paramstore_name)
  type        = "SecureString"
  value       = var.task_queue_name
}
