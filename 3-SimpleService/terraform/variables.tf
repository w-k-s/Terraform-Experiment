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
