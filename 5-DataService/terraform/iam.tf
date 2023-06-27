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
  name   = format("%s-download-app-policy", var.project_id)
  path   = "/"
  policy = data.aws_iam_policy_document.download_app_policy_document.json
}

// Attaches a Managed IAM Policy to user(s), role(s), and/or group(s)
resource "aws_iam_role_policy_attachment" "download_app_policy_attachment" {
  role       = aws_iam_role.app_instance_role.name
  policy_arn = aws_iam_policy.download_app_policy.arn
}


# Using session manager to access ec2 instance (rather than using key-pairs and ssh)
# An AWS ISM policy that grants Session Manager the permission to perform actions on your Amazon EC2 managed instances
# https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-create-iam-instance-profile.html
data "aws_iam_policy_document" "session_management_policy_document" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel*",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "s3:GetEncryptionConfiguration"
    ]

    resources = [
      "*",
    ]
  }

}

resource "aws_iam_policy" "session_management_policy" {
  name   = format("%s-session-management-policy", var.project_id)
  path   = "/"
  policy = data.aws_iam_policy_document.session_management_policy_document.json
}

resource "aws_iam_role_policy_attachment" "session_management_policy_attachment" {
  role       = aws_iam_role.app_instance_role.name
  policy_arn = aws_iam_policy.session_management_policy.arn
}

# Policy that enables EC2 instance to act as a CloudWatch Agent Server
data "aws_iam_policy" "cloudwatch_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = aws_iam_role.app_instance_role.name
  policy_arn = data.aws_iam_policy.cloudwatch_policy.arn
}

# Policy that enables AWS Systems Manager service core functionality
data "aws_iam_policy" "ssm_access_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm_access_policy_attachment" {
  role       = aws_iam_role.app_instance_role.name
  policy_arn = data.aws_iam_policy.ssm_access_policy.arn
}

# This particular action is required in order for the Spring Application running in EC2
# to be able to fetch the configs from parameter store.
# For Spring Config Import, The coniguration keys in parameter store have the format /config/appName_profile/configName.
# As the keys use a path structure. the `GetParametersByPath` action is required.
# This action is not included in the AmazonSSMManagedInstanceCore policy so it needs to be added explicitly.
data "aws_iam_policy_document" "get_parameter_by_path_policy_document" {
  statement {
    sid = "1"

    actions = [
      "ssm:GetParametersByPath"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "get_parameter_by_path_policy" {
  name   = format("%s-get-parameter-by-path-policy", var.project_id)
  path   = "/"
  policy = data.aws_iam_policy_document.get_parameter_by_path_policy_document.json
}


resource "aws_iam_role_policy_attachment" "get_parameter_by_path_policy_attachment" {
  role       = aws_iam_role.app_instance_role.name
  policy_arn = aws_iam_policy.get_parameter_by_path_policy.arn
}

// The instance profile contains the role and can provide the role's temporary credentials to an application that runs on the instance
// Note that only one role can be assigned to an Amazon EC2 instance at a time, and all applications on the instance share the same role and permissions.
resource "aws_iam_instance_profile" "app_instance_profile" {
  name = format("%s-app-instance-profile", var.project_id)
  role = aws_iam_role.app_instance_role.name
}
