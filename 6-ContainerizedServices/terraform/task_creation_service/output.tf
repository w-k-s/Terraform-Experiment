output "api_gateway_integration" {
  value = aws_apigatewayv2_integration.this
}

output "api_gateway_route" {
  value = aws_apigatewayv2_route.tasks_subresource_route
}
