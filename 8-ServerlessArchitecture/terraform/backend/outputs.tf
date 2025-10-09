
output "api_endpoint" {
  value       = aws_apigatewayv2_api.todo_api.api_endpoint
  description = "The API Endpoint"
}

output "cloudfront_domain" {
  value       = aws_cloudfront_distribution.todo_cf.domain_name
  description = "CloudFront distribution domain name (use this or your custom alias)"
}
