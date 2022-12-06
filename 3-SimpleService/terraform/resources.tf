resource "aws_s3_bucket_object" "app_executable" {
  bucket = aws_s3_bucket.app_bucket.id
  key = "executable"
  source = "target/myapp-${var.myapp_version}.jar"
}