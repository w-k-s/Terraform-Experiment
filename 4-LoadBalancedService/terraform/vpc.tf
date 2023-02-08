resource "aws_default_vpc" "this" {

}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.vpc_id]
  }

  filter {
    name   = "tag:Public"
    values = ["1"]
  }
}
