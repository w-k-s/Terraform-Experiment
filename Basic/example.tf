# block is required so Terraform knows which provider to download from the Terraform Registry.
# https://registry.terraform.io/
terraform {
  required_providers {
    aws = {
      # shorthand for registry.terraform.io/hashicorp/aws
      source  = "hashicorp/aws"
      # The version argument is optional, but recommended. 
      # It is used to constrain the provider to a specific version or a range of versions in order to prevent downloading a new provider that may possibly contain breaking changes
      version = "~> 3.27"
    }
  }

  # Store terraform state in s3 instead of locally
  # https://learn.hashicorp.com/tutorials/terraform/aws-remote?in=terraform/aws-get-started
  # https://www.terraform.io/docs/language/settings/backends/s3.html
  backend "s3" {
    # This assumes we have a bucket created called io.wks.terraform
    bucket = "io.wks.terraform"
    key    = "learn-terraform-aws-instance/state.json"
    region = "ap-south-1"
  }
}

# The provider block configures the named provider, in our case aws
# Multiple provider blocks can exist if a Terraform configuration manages resources from different providers.
provider "aws" {
  # The profile attribute in your provider block refers Terraform to 
  # the AWS credentials stored in your AWS Config File, 
  # which you created when you configured the AWS CLI.
  profile = "default"
  region  = "ap-south-1"
}

# The resource block defines a piece of infrastructure
# The resource block has two strings before the block: the resource type and the resource name. 
# The prefix of the type maps to the provider. In our case "aws_instance" automatically tells Terraform that it is managed by the "aws" provider.
resource "aws_instance" "example" {
  ami           = "ami-073c8c0760395aab8"
  instance_type = "t2.micro"
  tags = {
    Name = var.instance_name
  }
}