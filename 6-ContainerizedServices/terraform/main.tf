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
  source                              = "task_creation_service"
  aws_region                          = var.aws_region
  cluster_arn                         = aws_ecs_cluster.this.arn
  private_subnets                     = data.aws_subnets.private_subnets
  public_subnets                      = data.aws_subnets.public_subnets
  rds_security_group                  = data.aws_security_group.rds
  task_creation_service_image         = var.task_creation_service_image
  task_creation_service_conainer_port = var.task_creation_service_conainer_port
  cloudwatch_log_group                = aws_cloudwatch_log_group.this.name
  vpc_id                              = aws_default_vpc.this.id
  project_id                          = var.project_id
  api_gateway_id                      = aws_apigatewayv2_api.this.id
}
