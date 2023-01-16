variable "project_name" {
  type        = string
  description = "the name of the project"
  default     = "Unit Conversion Service"
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

variable "load_balanced_service_host" {
  type        = string
  description = "The host part of the api url. For example, the load_balanced_service_host for 'http://api.example.org' is 'api.example.org'"
}

variable "executable_jar_path" {
  type        = string
  description = "The absolute path to the compiled, executable jar. The jar at this path will be uploaded to S3" # Can this be relative? 
}

variable "application_log_directory" {
  type        = string
  description = "The absolute path to where the log files will be saved"
  default     = "/var/log/unit_conversion"
}

variable "application_log_file_name" {
  type        = string
  description = "The name of the log file (file extension must be provided) e.g. 'myapp.log'"
  default     = "application.log"
}

variable "log_group_name" {
  type        = string
  description = "CloudWatch log group name"
  default     = "UnitConversionService"
}
