# A private integration that uses a VPC link to encapsulate connections between API Gateway and Application Load Balancers
resource "aws_apigatewayv2_integration" "task_creation" {
  api_id             = var.api_gateway_id
  description        = "Task Monkey REST API"
  connection_id      = aws_apigatewayv2_vpc_link.task_creation.id
  connection_type    = "VPC_LINK"
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = aws_lb_listener.task_creation.arn
}

resource "aws_apigatewayv2_vpc_link" "task_creation" {
  name               = "${var.project_id}-Gateway-VPCLink"
  security_group_ids = ["${var.sg_vpc_link}"]
  subnet_ids         = var.public_subnets
}

resource "aws_apigatewayv2_route" "tasks_subresource_route" {
  api_id    = var.api_gateway_id
  route_key = "ANY /api/v1/tasks/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.task_creation.id}"
}

resource "aws_apigatewayv2_route" "tasks_resource_route" {
  api_id    = var.api_gateway_id
  route_key = "POST /api/v1/tasks"
  target    = "integrations/${aws_apigatewayv2_integration.task_creation.id}"
}

