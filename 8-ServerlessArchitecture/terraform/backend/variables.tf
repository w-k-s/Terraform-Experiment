variable "project_name" {
  type        = string
  description = "the name of the project"
  default     = "Toso Serverless"
}

variable "aws_region" {
  type        = string
  description = "The AWS region where the AWS resources will be deployed."
}

variable "aws_secretsmanager_secret_name" {
  type        = string
  description = "The name to assign to the AWS Secrets Manager secret that will store application secrets as a JSON object."
}
