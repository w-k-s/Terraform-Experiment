variable "domain_name" {
  type = string
  description = "The domain name for the website."
}

variable "bucket_name" {
  type = string
  description = "The name of the bucket without the www. prefix. Normally domain_name."
}

variable "route53_hosted_zone_id" {
  type = string
  description = "The id of the hosted zone where the static website will be deployed."
}