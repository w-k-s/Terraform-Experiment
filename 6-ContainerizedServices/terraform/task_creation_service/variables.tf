variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "cluster_arn" {
  type        = string
  description = "Cluster ARN"
}

variable "private_subnets" {
  type        = list(any)
  description = "Private Subnets"
}

variable "public_subnets" {
  type        = list(any)
  description = "Public Subnet Ids"
}

variable "task_creation_service_conainer_port" {
  type        = number
  description = "Port on which application inside container is listening e.g. 8080"
}

variable "task_creation_service_image" {
  type        = string
  description = "Image for the task creation service"
}

variable "cloudwatch_log_group" {
  type        = string
  description = "Cloudwatch Log Group"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "project_id" {
  type        = string
  description = "6-character project id e.g. food, shop, health, fin"
}

variable "api_gateway_id" {
  type        = string
  description = "The ID of the API Gateway through which this microservice will be exposed"
}

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