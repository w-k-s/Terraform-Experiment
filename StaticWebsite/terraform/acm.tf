resource "aws_acm_certificate" "cert" {
  provider = aws.acm_provider
  domain_name       = var.domain_name
  validation_method = "EMAIL"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider = aws.acm_provider
  certificate_arn = aws_acm_certificate.cert.arn
}