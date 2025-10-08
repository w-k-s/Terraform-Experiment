
output "api_endpoint" {
  value       = aws_apigatewayv2_api.todo_api.api_endpoint
  description = "The API Endpoint"
}
