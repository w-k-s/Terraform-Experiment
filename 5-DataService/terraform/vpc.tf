resource "aws_default_vpc" "this" {

}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.this.id]
  }

  filter {
    name   = "tag:Public"
    values = ["1"]
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.this.id]
  }

  filter {
    name   = "tag:Public"
    values = ["0"]
  }
}

data "aws_route_table" "private_route_table" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.this.id]
  }

  filter {
    name   = "tag:Public"
    values = ["0"]
  }
}

# Access Amazon S3 from your VPC using gateway VPC endpoints
# This is to enable the EC2 instance to download the application artifact from S3.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_default_vpc.this.id
  service_name      = format("com.amazonaws.%s.s3", var.aws_region)
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [data.aws_route_table.private_route_table.id]

  tags = {
    Name = format("%s-vpclink-s3",var.project_id)
  }
}

# Add a VPC endpoint for SSM so that the EC2 instance can talk to the session manager
resource "aws_vpc_endpoint" "ssm" {
  vpc_id       = aws_default_vpc.this.id
  service_name = format("com.amazonaws.%s.ssm", var.aws_region)
  vpc_endpoint_type = "Interface"

  tags = {
    Name = format("%s-vpclink-ssm",var.project_id)
  }
}

# Add a VPC endpoint for SSM so that the EC2 instance can talk to the session manager
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id       = aws_default_vpc.this.id
  service_name = format("com.amazonaws.%s.ec2messages", var.aws_region)
  vpc_endpoint_type = "Interface"

  tags = {
    Name = format("%s-vpclink-ec2messages",var.project_id)
  }
}

# Add a VPC endpoint for SSM so that the EC2 instance can talk to the session manager
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id       = aws_default_vpc.this.id
  service_name = format("com.amazonaws.%s.ssmmessages", var.aws_region)
  vpc_endpoint_type = "Interface"

  tags = {
    Name = format("%s-vpclink-ssmmessages",var.project_id)
  }
}