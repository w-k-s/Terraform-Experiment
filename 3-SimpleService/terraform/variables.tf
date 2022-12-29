variable "project_name" {
  type        = string
  description = "the name of the project"
  default     = "Simple Service"
}

variable "aws_region"{
  type        = string
  description = "AWS Region"
  default     = "ap-south-1"
}

variable "hosted_zone_name" {
  type        = string
  description = "The hosted zone domain name. For example, the hosted_zone_name for 'http://api.example.org' is 'example.org'"
}

variable "simple_service_host" {
  type        = string
  description = "The host part of the api url. For example, the api_gateway_host for 'http://api.example.org' is 'api.example.org'"
}

variable "executable_jar_path" {
  type        = string
  description = "The absolute path to the executable jar" # Can this be relative? 
}

variable "private_key_output_file" {
  type        = string
  description = "The path where the private key should be saved (including the private key file name) e.g. /User/example/.ssh/my-private-key.pem"
}

variable "ec2_key_pair_name" {
  type        = string
  description = "The name of the key pair to be used to ssh to the EC2 instance"
  default     = "app_instance_key_pair"
}
