terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }

    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.19.0"
    }
  }

  backend "s3" {
    # This assumes we have a bucket created called io.wks.terraform
    bucket = "io.wks.terraform"
    key    = "notice-board-service.state.json"
    region = "ap-south-1"
  }

  required_version = ">= 1.3.0"
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
  region = "ap-south-1"
}

module "task_creation_service" {
  source     = "./task_creation_service"
  project_id = var.project_id

  # API Gateway
  api_gateway_id = aws_apigatewayv2_api.this.id

  # DB
  db_endpoint = data.aws_db_instance.database.endpoint
  db_name     = var.rds_psql_application_db_name
  db_username = var.rds_psql_application_role
  db_password = var.rds_psql_application_password

  # VPC
  aws_region      = var.aws_region
  vpc_id          = aws_default_vpc.this.id
  private_subnets = data.aws_subnets.private_subnets.ids
  public_subnets  = data.aws_subnets.public_subnets.ids

  # ECS
  cluster_arn                         = aws_ecs_cluster.this.arn
  task_creation_service_image         = var.task_creation_service_image
  task_creation_service_conainer_port = var.task_creation_service_conainer_port

  # SQS
  task_queue_name = aws_sqs_queue.tasks.name

  # Cloud Watch
  cloudwatch_log_group = aws_cloudwatch_log_group.this.name

  # Security Groups
  sg_vpc_link      = aws_security_group.vpc_link.id
  sg_load_balancer = aws_security_group.load_balancer.id
  sg_app           = aws_security_group.app.id
}
