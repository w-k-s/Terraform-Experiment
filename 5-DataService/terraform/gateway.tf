resource "aws_apigatewayv2_api" "this" {
  name                         = "Notice Board REST API"
  description                  = "Post notices for anyone to read"
  protocol_type                = "HTTP"
  disable_execute_api_endpoint = true
}

# A private integration that uses a VPC link to encapsulate connections between API Gateway and Application Load Balancers
resource "aws_apigatewayv2_integration" "this" {
  api_id             = aws_apigatewayv2_api.this.id
  description        = "Notice Board REST API"
  connection_id      = aws_apigatewayv2_vpc_link.this.id
  connection_type    = "VPC_LINK"
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = aws_lb_listener.listener_http.arn
}

resource "aws_apigatewayv2_vpc_link" "this" {
  name               = format("%s-Gateway-VPCLink", var.project_id)
  security_group_ids = ["${aws_security_group.vpc_link.id}"]
  subnet_ids         = data.aws_subnets.public_subnets.ids
}

resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id        = aws_apigatewayv2_api.this.id
  name          = "dev"
  deployment_id = aws_apigatewayv2_deployment.this.id
  auto_deploy = true
}

resource "aws_apigatewayv2_deployment" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  description = "Deployment"

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_apigatewayv2_integration.this),
      jsonencode(aws_apigatewayv2_route.this),
    ])))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_domain_name" "this" {
  domain_name = var.notice_board_service_host

  domain_name_configuration {
    certificate_arn = aws_acm_certificate_validation.cert_validation.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "example" {
  api_id      = aws_apigatewayv2_api.this.id
  domain_name = aws_apigatewayv2_domain_name.this.id
  stage       = aws_apigatewayv2_stage.dev.id
}
