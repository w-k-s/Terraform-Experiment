resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  description = "Cloudwatch agent config to configure custom log"
  name        = "/cloudwatch-agent/config"
  type        = "String"
  value = templatefile("amazon-cloudwatch-agent.json", {
    application_log_directory = var.application_log_directory
    application_log_file_name = var.application_log_file_name
    project_name              = var.log_group_name
  })
}