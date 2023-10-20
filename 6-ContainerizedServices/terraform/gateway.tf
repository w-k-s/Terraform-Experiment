resource "aws_apigatewayv2_api" "this" {
  name                         = "Task Monkey REST API"
  description                  = "On-demand task outsourcing"
  protocol_type                = "HTTP"
  disable_execute_api_endpoint = false # Set to true for "production"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id        = aws_apigatewayv2_api.this.id
  name          = "dev"
  deployment_id = aws_apigatewayv2_deployment.this.id
  auto_deploy   = false
}

resource "aws_apigatewayv2_domain_name" "this" {
  domain_name = var.containerized_app_host

  domain_name_configuration {
    certificate_arn = aws_acm_certificate_validation.cert_validation.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
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
      jsonencode(module.task_creation_service.api_gateway_integration),
      jsonencode(flatten(module.task_creation_service.api_gateway_route)),
    ])))
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_apigatewayv2_api_mapping" "example" {
  api_id      = aws_apigatewayv2_api.this.id
  domain_name = aws_apigatewayv2_domain_name.this.id
  stage       = aws_apigatewayv2_stage.dev.id
}
