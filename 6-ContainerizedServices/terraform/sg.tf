resource "aws_security_group" "vpc_link" {
  name_prefix = "vpclink_sg_"
  description = "Allow HTTP inbound traffic"
  vpc_id = aws_default_vpc.this.id

  ingress {
    description      = "Allow http traffic from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Allow https traffic from anywhere"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
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
    Name = format("%s-sg-vpclink", var.project_id)
  }
}

resource "aws_security_group" "load_balancer" {
  name_prefix = "lb_sg_"
  description = "Application Load Balance Security Group"
  vpc_id = aws_default_vpc.this.id

  ingress {
    description      = "Allow http traffic from vpc link"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_groups  = ["${aws_security_group.vpc_link.id}"]
  }

  ingress {
    description      = "Allow https traffic from vpc link"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_groups  = ["${aws_security_group.vpc_link.id}"]
  }

  ingress {
    description      = "Allow http traffic from application"
    from_port        = var.application_listen_port
    to_port          = var.application_listen_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_groups  = ["${aws_security_group.vpc_link.id}"]
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
    Name = format("%s-sg-lb", var.project_id)
  }
}



# For Fargate, The security group attached to the VPC endpoint must allow incoming connections on TCP port 443 from the private subnet of the VPC.
# References: 
# - https://docs.aws.amazon.com/AmazonECS/latest/developerguide/vpc-endpoints.html
# - https://hands-on.cloud/aws-fargate-private-vpc-terraform-example/
resource "aws_security_group" "vpc_endpoint" {
  name   = "vpce_sg_"
  vpc_id = aws_default_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.this.cidr_block]
  }

  tags = {
    Name = format("%s-sg-vpce", var.project_id)
  }
}

resource "aws_security_group" "app" {
  name_prefix = "app_sg_"
  description = "Application instance security group"
  vpc_id = aws_default_vpc.this.id

  ingress {
    from_port   = var.application_listen_port
    to_port     = var.application_listen_port
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = format("%s-sg-instance", var.project_id)
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
