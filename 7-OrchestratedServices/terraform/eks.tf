locals {
  cluster_name = "${var.project_id}-Cluster"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = local.cluster_name
  cluster_version = "1.27"

  vpc_id                         = aws_default_vpc.this.id
  subnet_ids                     = data.aws_subnets.private_subnets.*.id

  # Indicates whether or not the Amazon EKS public API server endpoint is enabled
  # If set to false, API will only be accessible within this VPC.
  # Specifically, kubectl commands will only work within this VPC.
  cluster_endpoint_public_access = true

  # With Amazon EKS managed node groups, you don't need to separately provision or register the Amazon EC2 instances that provide compute capacity to run your Kubernetes applications
  # Every managed node is provisioned as part of an Amazon EC2 Auto Scaling group that's managed for you by Amazon EKS. 
  # Every resource including the instances and Auto Scaling groups runs within your AWS account. 
  # Each node group runs across multiple Availability Zones that you define.
  eks_managed_node_groups = {

    blue = {}
    green = {
      
      name =  "${var.project_id}-OnDemand"
      use_name_prefix = false # Use name as-is, not as a prefix.

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
      # We could make another nodegroup of spot instances if we wanted.
      capacity_type  = "ON_DEMAND"
    }
  }

}