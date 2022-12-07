resource "aws_s3_bucket" "app_bucket" {
  bucket = "io.wks.terraform.todobackend"
  acl    = "private"
}

resource "aws_s3_object" "app" {
  bucket = aws_s3_bucket.app_bucket.id
  key    = "app.jar"
  acl    = "private"
  source = var.executable_jar_path
  etag   = filemd5(var.executable_jar_path)
}
