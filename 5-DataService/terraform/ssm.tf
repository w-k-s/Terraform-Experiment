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

resource "aws_ssm_parameter" "cognito_client_id" {
  description = "Cognito Client ID"
  name        = format("/config/%s/spring.security.oauth2.client.registration.cognito.clientId", var.project_id)
  type        = "String"
  value       = aws_cognito_user_pool_client.this.id
}

resource "aws_ssm_parameter" "cognito_client_secret" {
  description = "Cognito Client Secret"
  name        = format("/config/%s/spring.security.oauth2.client.registration.cognito.clientSecret", var.project_id)
  type        = "SecureString"
  value       = aws_cognito_user_pool_client.this.client_secret
}

resource "aws_ssm_parameter" "cognito_client_redirect_uri" {
  description = "Cognito Client Scope"
  name        = format("/config/%s/spring.security.oauth2.client.registration.cognito.redirect-uri", "openid")
  type        = "String"
  value       = "http://localhost:8080/login/oauth2/code/cognito"
}

resource "aws_ssm_parameter" "cognito_client_name" {
  description = "Cognito Client Scope"
  name        = format("/config/%s/spring.security.oauth2.client.registration.cognito.clientName", "openid")
  type        = "String"
  value       = aws_cognito_user_pool_client.this.name
}

resource "aws_ssm_parameter" "cognito_client_issuer_uri" {
  description = "Cognito Client Scope"
  name        = format("/config/%s/spring.security.oauth2.client.provider.issuerUri", "openid")
  type        = "String"
  value       = format("https://cognito-idp.%s.amazonaws.com/%s", var.aws_region, aws_cognito_user_pool.this.id)
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
