# A private integration that uses a VPC link to encapsulate connections between API Gateway and Application Load Balancers
resource "aws_apigatewayv2_integration" "task_feed" {
  api_id             = var.api_gateway_id
  description        = "Task Monkey REST API"
  connection_id      = aws_apigatewayv2_vpc_link.task_feed.id
  connection_type    = "VPC_LINK"
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = aws_lb_listener.task_feed.arn
}

resource "aws_apigatewayv2_vpc_link" "task_feed" {
  name               = "${var.project_id}-Gateway-VPCLink"
  security_group_ids = ["${var.sg_vpc_link}"]
  subnet_ids         = var.public_subnets
}

resource "aws_apigatewayv2_route" "taskers_subresource_route" {
  api_id    = var.api_gateway_id
  route_key = "ANY /api/v1/taskers/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.task_feed.id}"
}

resource "aws_apigatewayv2_route" "taskers_resource_route" {
  api_id    = var.api_gateway_id
  route_key = "POST /api/v1/taskers"
  target    = "integrations/${aws_apigatewayv2_integration.task_feed.id}"
}

