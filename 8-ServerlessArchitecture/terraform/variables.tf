variable "project_name" {
  type        = string
  description = "the name of the project"
  default     = "Toso Serverless"
}

variable "aws_region" {
  type        = string
  description = "The AWS region where the AWS resources will be deployed."
}

variable "lambda_s3_bucket" {
  type        = string
  description = "S3 bucket where lambda zip file is stored."
}

variable "lambda_s3_key" {
  type        = string
  description = "S3 object key of the lambda zip file"
}
