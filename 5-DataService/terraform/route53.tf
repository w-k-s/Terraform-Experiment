data "aws_route53_zone" "api_zone" {
  name         = var.hosted_zone_name
  private_zone = false
}

resource "aws_route53_record" "root-a" {
  zone_id = data.aws_route53_zone.api_zone.zone_id
  name    = aws_apigatewayv2_domain_name.this.domain_name
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.this.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.this.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "auth-cognito-A" {
  zone_id = data.aws_route53_zone.api_zone.zone_id
  name    = aws_cognito_user_pool_domain.main.domain
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = aws_cognito_user_pool_domain.main.cloudfront_distribution
    zone_id                = aws_cognito_user_pool_domain.main.cloudfront_distribution_zone_id
  }
}