resource "aws_cloudwatch_log_group" "todo_logs" {
  name              = "Simple-Service-Execution-Logs_${aws_api_gateway_rest_api.todo_rest_api.id}/dev"
  retention_in_days = 7
}
