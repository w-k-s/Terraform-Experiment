variable "project_name" {
  type        = string
  description = "the name of the project"
  default     = "Task Monkey"
}

variable "project_id" {
  type        = string
  description = "6-character project id e.g. food, shop, health, fin"
  default     = "tskmnk"
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

variable "containerized_app_host" {
  type        = string
  description = "The host part of the api url. For example, the containerized_app_host for 'http://api.example.org' is 'api.example.org'"
}

variable "task_creation_service_image" {
  type        = string
  description = "Image for the task creation service."
}

variable "task_feed_service_image" {
  type        = string
  description = "Image for the task feed service."
}

variable "application_listen_port" {
  type        = number
  description = "Port on which the task creation service application inside container is listening"
  default     = 8080
}

variable "rds_psql_instance_identifier" {
  type        = string
  description = "Existing RDS PSQL instance identifier"
}

variable "rds_psql_master_username" {
  type        = string
  description = "Master username for PSQL database. This role must be able to create databases"
}

variable "rds_psql_master_password" {
  type        = string
  description = "Master password for PSQL database"
}

variable "rds_psql_application_db_name" {
  type        = string
  description = "The name of the database to create on the RDS PSQL instance for this application"
  default     = "taskmonkey"
}


variable "rds_psql_application_role" {
  type        = string
  description = "The name of the role used by the application to connect to the application db"
  default     = "taskmonkey_user"
}

variable "rds_psql_application_password" {
  type        = string
  description = "The password of the role used by the application to connect to the application db"
  default     = "taskmonkey_password"
}


