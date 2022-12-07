variable "project_name" {
  type        = string
  description = "the name of the project"
  default     = "Simple Service"
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

variable "ec2_key_pair_name" {
  type        = string
  description = "The name used for the EC2 instance(s) key pair"
  default     = "terraform_simple_service_key_pair"
}

variable "ec2_key_pair_public_key_content" {
  type        = string
  description = "The content of the public key used as the ec2 instance key pair"
}

