resource "aws_security_group" "vpc_link" {
  name        = "vpc_link_sg"
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


resource "aws_security_group" "load_balancer" {
  name        = "load_balancer_sg"
  description = "Application Load Balance Security Group"

  ingress {
    description     = "TLS from Default VPC"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = ["${aws_security_group.vpc_link.id}"]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "instance" {
  name        = "instance_sg"
  description = "Application instance security group"

  ingress {
    description     = "TLS from Default VPC"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.load_balancer.id}"]
  }

  ingress {
    description     = "From RDS instance"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${data.aws_security_group.rds.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
