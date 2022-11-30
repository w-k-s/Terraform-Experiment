variable "hosted_zone_name" {
  type        = string
  description = "Hosted zone domain name"
}

variable "bucket_name" {
  type        = string
  description = "The name of the bucket without the www. prefix. Normally domain_name."
}

variable "static_website_host" {
  type        = string
  description = "The url host of the website e.g. terraform.example.com"
  default     = format("terraform.%s", var.domain_name)
}