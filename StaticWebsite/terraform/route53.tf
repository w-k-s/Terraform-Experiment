resource "aws_route53_record" "root-a" {
  zone_id = var.route53_hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    # For S3 Website
    #name                   = aws_s3_bucket.bucket.website_endpoint
    #zone_id                = aws_s3_bucket.bucket.hosted_zone_id

    # For CloudFront Distribution
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}