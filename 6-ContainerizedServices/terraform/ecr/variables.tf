variable "aws_region" {
  type        = string
  description = "The AWS region where the AWS resources will be deployed."
  default     = "ap-south-1"
}

variable "project_name" {
  type        = string
  description = "the name of the project"
  default     = "Task Monkey"
}
