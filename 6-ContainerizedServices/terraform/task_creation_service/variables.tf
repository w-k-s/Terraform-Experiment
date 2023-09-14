variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "project_id" {
  type        = string
  description = "6-character project id e.g. food, shop, health, fin"
}

# API Gateway

variable "api_gateway_id" {
  type        = string
  description = "The ID of the API Gateway through which this microservice will be exposed"
}

# DB

variable "db_endpoint" {
  type        = string
  description = "The RDS DB instance endpoint"
}

variable "db_name" {
  type        = string
  description = "The name of the database that the task creation service connect to"
}

variable "db_username" {
  type        = string
  description = "the username used by the task creation service to connect to the database"
}

variable "db_password" {
  type        = string
  description = "the password used by the task creation service to connect to the database"
}

variable "db_schema" {
  type        = string
  description = "the schema used by the task creation service"
  default     = "task_creation"
}

# VPC

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnets" {
  type        = list(any)
  description = "Private Subnets"
}

variable "public_subnets" {
  type        = list(any)
  description = "Public Subnet Ids"
}

# ECS

variable "cluster_arn" {
  type        = string
  description = "Cluster ARN"
}

variable "task_creation_service_conainer_port" {
  type        = number
  description = "Port on which the application running inside container is listening e.g. 8080"
}

variable "task_creation_service_image" {
  type        = string
  description = "Image for the task creation service"
}

# Cloud watch

variable "cloudwatch_log_group" {
  type        = string
  description = "Cloudwatch Log Group"
}

# SQS

variable "task_queue_name" {
  type        = string
  description = "The name of the SQS used by the task creation service to exchange tasks."
}

# Security Group

variable "sg_vpc_link" {
  type        = string
  description = "Security Group of the VPC Link between API Gateway and Internal Load Balancers"
}

variable "sg_load_balancer" {
  type        = string
  description = "Security Group of the Internal Load Balancers"
}

variable "sg_app" {
  type        = string
  description = "Security group of the application instance"
}

# Param Store

variable "paramstore_name" {
  type        = string
  description = "Paraneter store name. e.g. For a parameter named '/config/app/some.value', the paramstore name is 'app'"
  default     = "taskcreation"
}