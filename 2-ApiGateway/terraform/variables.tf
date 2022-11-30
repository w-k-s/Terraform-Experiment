variable "hosted_zone_name" {
  type        = string
  description = "The hosted zone domain name."
}

variable "api_gateway_host" {
  type        = string
  description = "The url host of the api e.g. api.example.com"
  default = format("api.%s",var.hosted_zone_name")
}