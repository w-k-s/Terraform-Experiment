resource "aws_s3_bucket" "app_bucket" {
  bucket = "io.wks.terraform.todobackend"
  acl    = "private"
}
