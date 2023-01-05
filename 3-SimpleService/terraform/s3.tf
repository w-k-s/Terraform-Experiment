resource "aws_s3_bucket" "app_bucket" {
  bucket        = "io.wks.terraform.todobackend"
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

resource "aws_s3_object" "cloudwatch_agent_config" {
  bucket = aws_s3_bucket.app_bucket.id
  key    = "amazon-cloudwatch-agent.json"
  acl    = "private"
  content_base64 = base64encode(templatefile("amazon-cloudwatch-agent.json", {
    application_log_directory = var.application_log_directory
    project_name              = trimspace(var.project_name)
  }))
}
