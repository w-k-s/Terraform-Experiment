resource "aws_api_gateway_rest_api" "todo_rest_api" {

  name        = "Todo REST API"
  description = "This API keeps track of todos"

  endpoint_configuration {
    types = ["EDGE"] # Automatically creates Cloudfront distribution
  }
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.todo_rest_api.id
  parent_id   = aws_api_gateway_rest_api.todo_rest_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.todo_rest_api.id
  parent_id   = aws_api_gateway_resource.api_resource.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.todo_rest_api.id
  resource_id   = aws_api_gateway_resource.proxy_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "backend_integration" {
  rest_api_id = aws_api_gateway_rest_api.todo_rest_api.id
  resource_id = aws_api_gateway_resource.proxy_resource.id
  http_method = aws_api_gateway_method.todo_method.proxy_method

  type = "HTTP_PROXY"
  # Proxying to an ec2's public ip is not a good idea. We'll use an ELB in a different recipe.
  uri                     = format("http://%s", aws_instance.app_instance.public_ip)
  integration_http_method = "ANY"
}

resource "aws_api_gateway_deployment" "todo_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.todo_rest_api.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy_resource.id,
      aws_api_gateway_method.proxy_method.id,
      aws_api_gateway_integration.backend_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.todo_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.todo_rest_api.id
  stage_name    = "dev"
}

resource "aws_api_gateway_domain_name" "api_domain" {
  domain_name     = var.simple_service_host
  certificate_arn = aws_acm_certificate.cert.arn
}

# connects the domain name to the api
resource "aws_api_gateway_base_path_mapping" "example" {
  api_id      = aws_api_gateway_rest_api.todo_rest_api.id
  stage_name  = aws_api_gateway_stage.dev.stage_name
  domain_name = aws_api_gateway_domain_name.api_domain.domain_name
}

resource "aws_cloudwatch_log_group" "todo_logs" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.todo_rest_api.id}/dev"
  retention_in_days = 7
}