resource "aws_api_gateway_rest_api" "this" {

  name                         = "Notice Board REST API"
  description                  = "Post notices for anyone to read"
  disable_execute_api_endpoint = true

  endpoint_configuration {
    types = ["EDGE"] # Automatically creates Cloudfront distribution
  }
}

resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "backend_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this.id
  http_method             = "ANY"
  type                    = "HTTP_PROXY"
  connection_id           = aws_api_gateway_vpc_link.this.id
  connection_type         = "VPC_LINK"
  uri                     = format("http://%s/{proxy}", aws_lb.this.dns_name)
  integration_http_method = "ANY"

  cache_key_parameters = ["method.request.path.proxy"]

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

}

resource "aws_api_gateway_vpc_link" "this" {
  name        = format("%s-vpc-link", var.project_id)
  target_arns = [aws_lb.this.arn]
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.this.id,
      aws_api_gateway_method.this.id,
      aws_api_gateway_integration.backend_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "dev"
}

resource "aws_api_gateway_domain_name" "api_domain" {
  domain_name     = var.notice_board_service_host
  certificate_arn = aws_acm_certificate.cert.arn
}

# connects the domain name to the api
resource "aws_api_gateway_base_path_mapping" "example" {
  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.dev.stage_name
  domain_name = aws_api_gateway_domain_name.api_domain.domain_name
}