resource "aws_security_group" "vpc_link" {
  name_prefix = "vpclink_sg_"
  description = "Allow HTTP inbound traffic"

  tags = {
    Name = format("%s-sg-vpclink", var.project_id)
  }
}

resource "aws_security_group_rule" "vpc_link_http_ingress" {
  security_group_id = aws_security_group.vpc_link.id
  type              = "ingress"
  description       = "Allow http traffic from anywhere"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "vpc_link_https_ingress" {
  security_group_id = aws_security_group.vpc_link.id
  type              = "ingress"
  description       = "Allow https traffic from anywhere"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "vpc_link_egress" {
  security_group_id = aws_security_group.vpc_link.id
  type              = "egress"
  description       = "Allow all"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

# Load Balancer

resource "aws_security_group" "load_balancer" {
  name_prefix = "lb_sg_"
  description = "Application Load Balance Security Group"

<<<<<<< HEAD
  ingress {
    description     = "Allow http traffic from vpc link"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.vpc_link.id}"]
=======
  tags = {
    Name = format("%s-sg-lb", var.project_id)
>>>>>>> a8d2d4d13a1c30cdb918bfb8535e27410a4cad66
  }
}

<<<<<<< HEAD
  ingress {
    description     = "Allow https traffic from vpc link"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.vpc_link.id}"]
  }

  ingress {
    description     = "Allow http traffic from application"
    from_port       = var.application_listen_port
    to_port         = var.application_listen_port
    protocol        = "tcp"
    security_groups = ["${aws_security_group.app.id}"]
  }
=======

resource "aws_security_group_rule" "load_balancer_vpc_link_http_ingress" {
  security_group_id        = aws_security_group.load_balancer.id
  type                     = "ingress"
  description              = "Allow http traffic from vpc link"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  ipv6_cidr_blocks         = ["::/0"]
  source_security_group_id = aws_security_group.vpc_link.id
}
>>>>>>> a8d2d4d13a1c30cdb918bfb8535e27410a4cad66

resource "aws_security_group_rule" "load_balancer_vpc_link_https_ingress" {
  security_group_id        = aws_security_group.load_balancer.id
  type                     = "ingress"
  description              = "Allow https traffic from vpc link"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  ipv6_cidr_blocks         = ["::/0"]
  source_security_group_id = aws_security_group.vpc_link.id
}

resource "aws_security_group_rule" "load_balancer_app_ingress" {
  security_group_id        = aws_security_group.load_balancer.id
  type                     = "ingress"
  description              = "Allow http traffic from application"
  from_port                = var.application_listen_port
  to_port                  = var.application_listen_port
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  ipv6_cidr_blocks         = ["::/0"]
  source_security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "load_balancer_egress" {
  security_group_id = aws_security_group.load_balancer.id
  type              = "egress"

  description      = "Allow all"
  from_port        = 0
  to_port          = 0
  protocol         = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

# Application

resource "aws_security_group" "app" {
  name_prefix = "app_sg_"
  description = "Application instance security group"

  tags = {
    Name = format("%s-sg-app", var.project_id)
  }

}

resource "aws_security_group_rule" "app_http_ingress" {
  security_group_id = aws_security_group.app.id
  type              = "ingress"
  description       = "Allow HTTP from within VPC"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [aws_default_vpc.this.cidr_block]
}

resource "aws_security_group_rule" "app_https_ingress" {
  security_group_id = aws_security_group.app.id
  type              = "ingress"
  description       = "Allow HTTP from within VPC"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [aws_default_vpc.this.cidr_block]
}

resource "aws_security_group_rule" "app_lb_ingress" {
  security_group_id        = aws_security_group.app.id
  type                     = "ingress"
  description              = "Allow HTTP from Load Balancer"
  from_port                = var.application_listen_port
  to_port                  = var.application_listen_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "app_db_ingress" {
  security_group_id        = aws_security_group.app.id
  type                     = "ingress"
  description              = "Allow Postgres From RDS instance"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_group.rds.id
}

resource "aws_security_group_rule" "app_egress" {
  security_group_id = aws_security_group.app.id
  type              = "egress"
  description       = "Allow all"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group" "vpc_endpoint" {
  name_prefix = "vpcendp_sg_"
  description = "VPC Endpoint Security Group"


  ingress {
    description     = "Allow http traffic from application"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.app.id}"]
  }

  # For Fargate, The security group attached to the VPC endpoint must allow incoming connections on TCP port 443 from the private subnet of the VPC.
  # Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/vpc-endpoints.html
  ingress {
    description = "Allow https traffic from application"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.this.cidr_block]
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

# The existing RDS instance is in the default VPC.
# Here, we load a security group that is attached to the RDS instance.
# This security group allows all egress traffic on port 5432.
# It allows all ingress traffic from within the default VPC.
# We load this security group to attach it to the Application instance.
data "aws_security_group" "rds" {
  name = "DefaultVPC-PostgresqlDB-SecurityGroup"
}
