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

# TODO: Add this to private route table
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_default_vpc.this.id
  service_name = format("com.amazonaws.%s.s3", var.aws_region)
}