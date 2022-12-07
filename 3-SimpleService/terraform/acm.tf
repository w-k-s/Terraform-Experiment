resource "aws_acm_certificate" "cert" {
  provider          = aws.acm_provider
  domain_name       = var.simple_service_host
  validation_method = "DNS"

  lifecycle {
    # First create a new certificate before destroying the existing one.
    create_before_destroy = true
  }
}


resource "aws_route53_record" "dns_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.api_zone.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.acm_provider
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.dns_validation : record.fqdn]
}
