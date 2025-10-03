terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.15.0"
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
