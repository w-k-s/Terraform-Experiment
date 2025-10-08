variable "project_name" {
  type        = string
  description = "the name of the project"
  default     = "Todo Serverless"
}

variable "aws_region" {
  type        = string
  description = "The AWS region where the AWS resources will be deployed."
}

variable "supabase_access_token" {
  type        = string
  description = "Access token used for authenticating with the Supabase API"
  sensitive   = true
}

variable "supabase_organization_id" {
  type        = string
  description = "Unique identifier of the Supabase organisation under which the project is managed."
}

variable "supabase_database_password" {
  type        = string
  description = "Password for the Supabase database instance"
  sensitive   = true
}

variable "supabase_region" {
  type        = string
  description = "Region where the Supabase project will be hosted"
}

variable "aws_secretsmanager_secret_name" {
  type        = string
  description = "The name to assign to the AWS Secrets Manager secret that will store application secrets as a JSON object."
}
