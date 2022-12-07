terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    # This assumes we have a bucket created called io.wks.terraform
    bucket = "io.wks.terraform"
    key    = "static-website.state.json"
    region = "ap-south-1"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-south-1"
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
