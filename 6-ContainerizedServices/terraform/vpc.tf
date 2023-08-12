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
    Name = format("%s-vpcendp-s3", var.project_id)
  }
}

# Add a VPC endpoint for SSM so that the EC2 instance can talk to the session manager (also to get parameters)
resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = aws_default_vpc.this.id
  service_name       = format("com.amazonaws.%s.ssm", var.aws_region)
  vpc_endpoint_type  = "Interface"
  subnet_ids         = data.aws_subnets.private_subnets.ids
  security_group_ids = ["${aws_security_group.vpc_endpoint.id}"]
  # Requests to cloudwatch will resolve to vpc endpoint, rather than public url
  private_dns_enabled = true

  tags = {
    Name = format("%s-vpcendp-ssm", var.project_id)
  }
}

# Add a VPC endpoint for SSM so that the EC2 instance can talk to the session manager
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id             = aws_default_vpc.this.id
  service_name       = format("com.amazonaws.%s.ec2messages", var.aws_region)
  vpc_endpoint_type  = "Interface"
  subnet_ids         = data.aws_subnets.private_subnets.ids
  security_group_ids = ["${aws_security_group.vpc_endpoint.id}"]
  # Requests to cloudwatch will resolve to vpc endpoint, rather than public url
  private_dns_enabled = true

  tags = {
    Name = format("%s-vpcendp-ec2messages", var.project_id)
  }
}

# Add a VPC endpoint for SSM so that the EC2 instance can talk to the session manager
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id             = aws_default_vpc.this.id
  service_name       = format("com.amazonaws.%s.ssmmessages", var.aws_region)
  vpc_endpoint_type  = "Interface"
  subnet_ids         = data.aws_subnets.private_subnets.ids
  security_group_ids = ["${aws_security_group.vpc_endpoint.id}"]
  # Requests to cloudwatch will resolve to vpc endpoint, rather than public url
  private_dns_enabled = true

  tags = {
    Name = format("%s-vpcendp-ssmmessages", var.project_id)
  }
}

# Add a VPC endpoint for SSM so that the EC2 instance can send out logs
resource "aws_vpc_endpoint" "logs" {
  vpc_id             = aws_default_vpc.this.id
  service_name       = format("com.amazonaws.%s.logs", var.aws_region)
  vpc_endpoint_type  = "Interface"
  subnet_ids         = data.aws_subnets.private_subnets.ids
  security_group_ids = ["${aws_security_group.vpc_endpoint.id}"]
  # Requests to cloudwatch will resolve to vpc endpoint, rather than public url
  private_dns_enabled = true

  tags = {
    Name = format("%s-vpcendp-logs", var.project_id)
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name = format("%s-nat-eip", var.project_id)
  }
}

# The EC2 instances download Java19 from oracle (could download from s3), so a nat gateway is needed.
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(data.aws_subnets.public_subnets.ids, 1)

  tags = {
    Name = format("%s-nat-gateway", var.project_id)
  }
}

resource "aws_route" "nat_gateway_ipv4" {
  route_table_id         = data.aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}