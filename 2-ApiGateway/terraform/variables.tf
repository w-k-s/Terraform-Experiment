variable "domain_name" {
  type        = string
  description = "The domain name for the website."
}

variable "route53_hosted_zone_id" {
  type        = string
  description = "The id of the hosted zone where the static website will be deployed."
}