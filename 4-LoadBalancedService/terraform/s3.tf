resource "aws_s3_bucket" "app_bucket" {
  bucket        = "io.wks.terraform.unit-conversion-backend"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "app_bucket_acl" {
  bucket = aws_s3_bucket.app_bucket.id
  acl    = "private"
}

resource "aws_s3_object" "app" {
  bucket = aws_s3_bucket.app_bucket.id
  key    = "app.jar"
  acl    = "private"
  source = var.executable_jar_path
  //etag   = filemd5(var.executable_jar_path) // TODO: File doesn't exist when destroying.
}
