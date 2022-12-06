resource "aws_s3_bucket" "app_bucket" {
  bucket = var.app_bucket_name
  acl = "private"
}