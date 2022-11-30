variable "hosted_zone_name" {
  type        = string
  description = "The hosted zone domain name. For example, the hosted_zone_name for 'http://web.example.org' is 'example.org'"
}

variable "bucket_name" {
  type        = string
  description = "The name of the bucket without the www. prefix. Normally domain_name."
}

variable "static_website_host" {
  type        = string
  description = "The host part of the website url. For example, the static_website_host for 'http://web.example.org' is 'web.example.org'"
}