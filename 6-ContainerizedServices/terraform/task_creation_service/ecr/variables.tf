variable "aws_region" {
  type        = string
  description = "The AWS region where the AWS resources will be deployed."
  default     = "ap-south-1"
}

variable "repository_name" {
  type        = string
  description = "the name of the project"
  default     = "w-k-s/terraform-task-monkey/task-creation"
}

variable "project_name" {
  type        = string
  description = "the name of the project"
  default     = "Task Monkey"
}
