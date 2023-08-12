resource "aws_cloudwatch_log_group" "this" {
  name              = var.project_id
  retention_in_days = 3
}
