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
  profile = "default"
  region  = "ap-south-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_website_configuration" "website"{
  bucket = aws_s3_bucket.bucket.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.website_policy.json
}

data "aws_iam_policy_document" "website_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }
}


resource "aws_route53_record" "root-a" {
  zone_id = var.route53_hosted_zone_id
  name = var.domain_name
  type = "A"

  alias {
    name                   = aws_s3_bucket.bucket.website_endpoint
    zone_id                = aws_s3_bucket.bucket.hosted_zone_id
    evaluate_target_health = false
  }
}