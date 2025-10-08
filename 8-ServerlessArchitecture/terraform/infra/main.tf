terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.15.0"
    }
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.0"
    }
  }

  backend "s3" {
    # This assumes we have a bucket created called io.wks.terraform
    bucket = "io.wks.terraform"
    key    = "infra.todo-serverless.state.json"
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

provider "supabase" {
  access_token = var.supabase_access_token
}

resource "supabase_project" "production" {
  organization_id   = var.supabase_organization_id
  name              = "todo-serverless"
  database_password = var.supabase_database_password
  region            = var.supabase_region

  lifecycle {
    ignore_changes = [database_password]
  }
}

data "supabase_pooler" "production" {
  project_ref = supabase_project.production.id
}

resource "aws_secretsmanager_secret" "main" {
  name = var.aws_secretsmanager_secret_name
}

locals {
  secrets_dictionary = {
    db_conn_string = replace(data.supabase_pooler.production.url.transaction, "[YOUR-PASSWORD]", var.supabase_database_password)
  }
}

resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = jsonencode(local.secrets_dictionary)
}
