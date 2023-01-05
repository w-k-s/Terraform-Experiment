resource "aws_iam_role" "app_instance_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "download_app_policy_document" {
  statement {
    sid = "1"

    actions = [
      "s3:GetObject",
      "s3:List*",
      "s3:HeadObject"
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.app_bucket.id}/*",
    ]
  }

}

resource "aws_iam_policy" "download_app_policy" {
  name   = "download_app_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.download_app_policy_document.json
}

// Attaches a Managed IAM Policy to user(s), role(s), and/or group(s)
resource "aws_iam_role_policy_attachment" "download_app_policy_attachment" {
  name       = "app_instance_policy_attachment"
  roles      = [aws_iam_role.app_instance_role.name]
  policy_arn = aws_iam_policy.download_app_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  name       = "cloudwatch_policy_attachment"
  roles      = [aws_iam_role.app_instance_role.name]
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

data "aws_iam_policy" "cloudwatch_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

// The instance profile contains the role and can provide the role's temporary credentials to an application that runs on the instance
// Note that only one role can be assigned to an Amazon EC2 instance at a time, and all applications on the instance share the same role and permissions.
resource "aws_iam_instance_profile" "app_instance_profile" {
  role = aws_iam_role.app_instance_role.name
}
