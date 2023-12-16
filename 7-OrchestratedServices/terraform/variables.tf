variable "project_name" {
  type        = string
  description = "the name of the project"
  default     = "Shopping"
}

variable "project_id" {
  type        = string
  description = "6-character project id e.g. food, shop, health, fin"
  default     = "shop"
}

variable "aws_region" {
  type        = string
  description = "The AWS region where the AWS resources will be deployed."
  default     = "ap-south-1"
}

variable "hosted_zone_name" {
  type        = string
  description = "The hosted zone domain name. For example, the hosted_zone_name for 'http://api.example.org' is 'example.org'"
}