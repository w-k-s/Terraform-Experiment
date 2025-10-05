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
    key    = "serverless.state.json"
    region = "ap-south-1"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project = var.project_name
    }
  }
}

provider "aws" {
  # We need the ACM certificate to be created in us-east-1 for Cloudfront to be able to use it
  alias  = "acm_provider"
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

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../backend/index.js"
  output_path = "../backend/function.zip"
}

resource "aws_lambda_function" "todo_lambda" {
  function_name    = "todoLambda"
  filename         = data.archive_file.lambda_zip.output_path
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
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
