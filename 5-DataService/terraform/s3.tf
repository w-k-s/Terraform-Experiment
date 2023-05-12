# ACLs are disabled, and the bucket owner automatically owns and has full control over every object in the bucket
resource "aws_s3_bucket" "app_bucket" {
  bucket        = "io.wks.terraform.notice-board-backend"
  force_destroy = true
}

resource "aws_s3_object" "app" {
  bucket = aws_s3_bucket.app_bucket.id
  key    = "app.jar"
  source = var.executable_jar_path
  //etag   = filemd5(var.executable_jar_path) // TODO: File doesn't exist when destroying.
}
