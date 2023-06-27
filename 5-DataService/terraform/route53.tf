data "aws_route53_zone" "api_zone" {
  name         = var.hosted_zone_name
  private_zone = false
}

resource "aws_route53_record" "root-a" {
  zone_id = data.aws_route53_zone.api_zone.zone_id
  name    = aws_api_gateway_domain_name.api_domain.domain_name
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.api_domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.api_domain.cloudfront_zone_id
    evaluate_target_health = false
  }
}

