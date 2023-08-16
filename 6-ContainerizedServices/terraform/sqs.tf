resource "aws_sqs_queue" "tasks" {
  name                       = "io.wks.taskmonkey.queue.tasks"
  visibility_timeout_seconds = 1200 # 20 minutes
  # Dead letter queue not configured.
}