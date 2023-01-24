data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"

  ingress {
    description      = "TLS from Default VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "allow_https" {
  name        = "allow_https"
  description = "Allow HTTPS inbound traffic"

  ingress {
    description      = "TLS from Default VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_instance" "app_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = ["${aws_security_group.allow_http.id}", "${aws_security_group.allow_https.id}"]
  user_data = base64encode(templatefile("app_instance_user_data.sh", {
    aws_region                = var.aws_region
    jar_name                  = "app.jar"
    s3_app_bucket             = aws_s3_bucket.app_bucket.id
    application_log_directory = var.application_log_directory
    application_log_file_name = var.application_log_file_name
    ssm_cloudwatch_config     = aws_ssm_parameter.cloudwatch_agent_config.name
  }))
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.app_instance_profile.name

  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
    tags = {
      Name = "terraform-storage"
    }
  }

  tags = {
    Name = format("%s-app-instance", var.project_name)
  }
}
