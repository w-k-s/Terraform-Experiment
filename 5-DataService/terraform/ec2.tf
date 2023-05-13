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

# TODO: Replace with launch template
resource "aws_launch_configuration" "this" {
  name_prefix     = var.project_name
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = "t3.micro"
  security_groups = ["${aws_security_group.instance.id}"]
  user_data = base64encode(templatefile("app_instance_user_data.sh", {
    aws_region                = var.aws_region
    jar_name                  = "app.jar"
    s3_app_bucket             = aws_s3_bucket.app_bucket.id
    application_log_directory = var.application_log_directory
    application_log_file_name = var.application_log_file_name
    ssm_cloudwatch_config     = aws_ssm_parameter.cloudwatch_agent_config.name
  }))
  
  # TODO: Get Session manager to work!
  key_name                    = data.aws_key_pair.this.key_name
  associate_public_ip_address = true

  iam_instance_profile        = aws_iam_instance_profile.app_instance_profile.name

  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }
}

# Bastion Instance to create the required database and roles, if they don't already exist.
resource "aws_instance" "bastion_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  subnet_id              = element(data.aws_subnets.private_subnets.ids, 1)
  
  user_data = base64encode(templatefile("bastion_instance_user_data.sh", {
    db_init_script_ssm_param_name = aws_ssm_parameter.db_init_script.name
    aws_region = var.aws_region
    rds_psql_master_password = var.rds_psql_master_username
    rds_psql_master_username = var.rds_psql_master_password
    db_address = data.aws_db_instance.database.address
    db_name = var.rds_psql_application_db_name
    db_port = data.aws_db_instance.database.port
  }))

  # TODO: Get Session manager to work!
  key_name                    = data.aws_key_pair.this.key_name
  associate_public_ip_address = true

  iam_instance_profile        = aws_iam_instance_profile.app_instance_profile.name

  tags = {
    Name = format("%s-bastion-instance", var.project_id)
  }
}

data "aws_key_pair" "this" {
  key_name           = "kp-aws-ap-south-1-mumbai"
  include_public_key = true
}


