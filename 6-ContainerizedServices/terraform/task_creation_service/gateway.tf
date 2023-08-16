# A private integration that uses a VPC link to encapsulate connections between API Gateway and Application Load Balancers
resource "aws_apigatewayv2_integration" "this" {
  api_id             = var.api_gateway_id
  description        = "Task Monkey REST API"
  connection_id      = aws_apigatewayv2_vpc_link.this.id
  connection_type    = "VPC_LINK"
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = aws_lb_listener.listener_http.arn
}

resource "aws_apigatewayv2_vpc_link" "this" {
  name               = format("%s-Gateway-VPCLink", var.project_id)
  security_group_ids = ["${aws_security_group.vpc_link.id}"]
  subnet_ids         = var.public_subnets
}

resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /api/v1/tasks{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}