resource "aws_security_group" "vpc_endpoint" {
  name_prefix = "vpcendp_sg_"
  description = "VPC Endpoint Security Group"


  ingress {
    description     = "Allow http traffic from application"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.instance.id}"]
  }

  ingress {
    description     = "Allow https traffic from application"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.instance.id}"]
  }

  egress {
    description      = "Allow all"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = format("%s-sg-vpcendp", var.project_id)
  }
}

resource "aws_security_group" "instance" {
  name_prefix = "app_sg_"
  description = "Application instance security group"

  ingress {
    description     = "Allow SSH from Bastion instance"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  # Security groups can not be attached to Network load balancers so we allow any http(s) traffic as long as it originates from within the VPC.
  # Allow http traffic from within vpc so that the ec2 instance can download jdk via nat gateway
  ingress {
    description = "Allow HTTP from within VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.this.cidr_block]
  }

  ingress {
    description = "Allow TLS from within VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.this.cidr_block]
  }

  ingress {
    description     = "Allow Postgres From RDS instance"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${data.aws_security_group.rds.id}"]
  }

  egress {
    description      = "Allow all"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = format("%s-sg-instance", var.project_id)
  }
}

resource "aws_security_group" "bastion" {
  name_prefix = "jump_sg_"
  description = "Bastion instance security group"

  ingress {
    description      = "SSH from Bastion instance"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # I don't have a static ip.
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    description      = "Allow all"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = format("%s-sg-bastion", var.project_id)
  }
}

# The existing RDS instance is in the default VPC.
# Here, we load a security group that is attached to the RDS instance.
# This security group allows all egress traffic on port 5432.
# It allows all ingress traffic from within the default VPC.
# We load this security group to attach it to the Application instance.
data "aws_security_group" "rds" {
  name = "DefaultVPC-PostgresqlDB-SecurityGroup"
}
