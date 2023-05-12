variable "project_name" {
  type        = string
  description = "the name of the project"
  default     = "Notice Board Service"
}

variable "project_id" {
  type        = string
  description = "6-character project id e.g. food, shop, health, fin"
  default     = "nboard"
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

variable "notice_board_service_host" {
  type        = string
  description = "The host part of the api url. For example, the notice_board_service_host for 'http://api.example.org' is 'api.example.org'"
}

variable "executable_jar_path" {
  type        = string
  description = "The absolute path to the compiled, executable jar. The jar at this path will be uploaded to S3" # Can this be relative? 
}

variable "rds_psql_instance_identifier" {
  type        = string
  description = "Existing RDS PSQL instance identifier"
}

variable "rds_psql_master_username" {
  type        = string
  description = "Master usename for PSQL dabatabase. This role must be able to create databases"
}

variable "rds_psql_master_password" {
  type        = string
  description = "Master password for PSQL dabatabase"
}

variable "rds_psql_application_db_name" {
  type        = string
  description = "The name of the database to create on the RDS PSQL instance for this application"
  default     = "noticeboard"
}

variable "rds_psql_application_schema" {
  type        = string
  description = "The name of the postgres schema used by the application"
  default     = "noticeboard"
}

variable "rds_psql_application_role" {
  type        = string
  description = "The name of the role used by the application to connect to the application db"
  default     = "noticeboarduser"
}

variable "rds_psql_application_password" {
  type        = string
  description = "The password of the role used by the application to connect to the application db"
  default     = "noticeboardpassword"
}

variable "application_log_directory" {
  type        = string
  description = "The absolute path to where the log files will be saved"
  default     = "/var/log/notice_board"
}

variable "application_log_file_name" {
  type        = string
  description = "The name of the log file (file extension must be provided) e.g. 'myapp.log'"
  default     = "application.log"
}


