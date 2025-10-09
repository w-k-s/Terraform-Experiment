terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.15.0"
    }
  }

  backend "s3" {
    # This assumes we have a bucket created called io.wks.terraform
    bucket = "io.wks.terraform"
    key    = "backend.todo-serverless.state.json"
    region = "ap-south-1"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project = var.project_name
      Name    = var.project_name
    }
  }
}

provider "aws" {
  # Cloudfront WAF must be created in us-east-1
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_secrets_managed" {
  role = aws_iam_role.lambda_exec.name
  # A little too permissive (we only need read), but okay for now
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}


data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../../backend/index.js"
  output_path = "../../backend/function.zip"
}

data "archive_file" "layer_zip" {
  type        = "zip"
  source_dir  = "../../backend/layer"
  output_path = "../../backend/nodejs.zip"
}

resource "aws_lambda_layer_version" "todo_layer" {
  filename            = data.archive_file.layer_zip.output_path
  layer_name          = "todo_layer"
  compatible_runtimes = ["nodejs20.x"]
  source_code_hash    = data.archive_file.layer_zip.output_base64sha256
}

resource "aws_lambda_function" "todo_lambda" {
  function_name    = "todoLambda"
  filename         = data.archive_file.lambda_zip.output_path
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 30

  layers = [aws_lambda_layer_version.todo_layer.arn]

  environment {
    variables = {
      AWS_SECRETSMANAGER_SECRET_NAME = var.aws_secretsmanager_secret_name
    }
  }
}

resource "aws_apigatewayv2_api" "todo_api" {
  name          = "todo-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.todo_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.todo_lambda.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "create_todo" {
  api_id    = aws_apigatewayv2_api.todo_api.id
  route_key = "POST /todo"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "list_todo" {
  api_id    = aws_apigatewayv2_api.todo_api.id
  route_key = "GET /todo"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}


resource "aws_apigatewayv2_route" "update_todo" {
  api_id    = aws_apigatewayv2_api.todo_api.id
  route_key = "PATCH /todo/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "delete_todo" {
  api_id    = aws_apigatewayv2_api.todo_api.id
  route_key = "DELETE /todo/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.todo_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.todo_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.todo_api.id
  name        = "$default"
  auto_deploy = true
}

locals {
  api_domain = replace(aws_apigatewayv2_api.todo_api.api_endpoint, "https://", "")
  origin_id  = "api-origin-${aws_apigatewayv2_api.todo_api.id}"
}

resource "aws_cloudfront_distribution" "todo_cf" {

  origin {
    domain_name = local.api_domain
    origin_id   = local.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront in front of todo-api"
  price_class         = "PriceClass_100"
  default_root_object = ""

  aliases = [] # We'll use the domain name provided by cloudfront

  default_cache_behavior {
    target_origin_id = local.origin_id
    # cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # AllViewerExceptHostHeader (Recommended for API GW)

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  web_acl_id = aws_wafv2_web_acl.cf_web_acl.arn

  # Wait for Lambda provisioning
  depends_on = [aws_lambda_permission.apigw_lambda]

}


resource "aws_wafv2_web_acl" "cf_web_acl" {
  provider    = aws.us_east_1
  name        = "${var.project_code}-cf-web-acl"
  description = "WAF Web ACL for CloudFront distribution"
  scope       = "CLOUDFRONT"
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = "${var.project_code}_cf_acl"
  }

  # See: https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-baseline.html
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${var.project_code}_common_rules"
    }
  }

  rule {
    # block requests from services that permit the obfuscation of viewer identity. These include requests from VPNs
    name     = "AWS-AWSManagedRulesAnonymousIpList"
    priority = 2
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${var.project_code}_anon_ip"
    }
  }

  rule {
    # rules to block request patterns that are known to be invalid and are associated with exploitation or discovery of vulnerabilities
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${var.project_code}_known_bad"
    }
  }

  rule {
    # block request patterns associated with exploitation of SQL databases, like SQL injection attacks
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 4
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${var.project_code}_sqli"
    }
  }

  rule {
    name     = "RateLimit_IP"
    priority = 5
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = 2000 # per 5 minutes
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${var.project_code}_rate_limit"
    }
  }

}
