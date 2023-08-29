# A role that ECS tasks can assume in order to call authenticated AWS APIs 
resource "aws_iam_role" "task_role" {
  name = "${var.project_id}-task_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "ssm_parameter_read_policy" {
  statement {
    sid = "1"

    actions = [
      "ssm:GetParametersByPath",
      "ssm:GetParameters"
    ]
  }
}

resource "aws_iam_policy" "ssm_parameter_read" {
  name        = "SSMParameterReadPolicy"
  description = "Policy to allow reading SSM parameters"
  policy      = data.aws_iam_policy_document.ssm_parameter_read_policy.json
}

resource "aws_iam_role_policy_attachment" "fargate_task_ssm_attachment" {
  policy_arn = aws_iam_policy.ssm_parameter_read.arn
  role       = aws_iam_role.task_role.name
}

# A role that ECS can assume in order to pull container images, store logs.
resource "aws_iam_role" "execution_role" {
  name = "${var.project_id}-ExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}
