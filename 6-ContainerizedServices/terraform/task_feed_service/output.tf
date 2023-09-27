output "api_gateway_integration" {
  value = aws_apigatewayv2_integration.task_feed
}

output "api_gateway_route" {
  value = aws_apigatewayv2_route.taskers_subresource_route
}
