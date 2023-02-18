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
  description = "Allow HTTP inbound traffic"

  ingress {
    description      = "TLS from Default VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
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
  description = "Allow Load balancer inbound traffic"

  ingress {
    description     = "TLS from Default VPC"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.load_balancer.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}