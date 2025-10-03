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
    key    = "shopping.orders.ecr.state.json"
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

resource "aws_ecr_repository" "order_service" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true # destroys repo even if it's not empty (not a good idea for production)

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
