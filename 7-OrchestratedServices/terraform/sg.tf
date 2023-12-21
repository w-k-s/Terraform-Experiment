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