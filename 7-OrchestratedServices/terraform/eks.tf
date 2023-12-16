provider "aws" {
  region = var.region
}

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
  subnet_ids                     = data.aws_subnets.private_subnets

  # Indicates whether or not the Amazon EKS public API server endpoint is enabled
  # If set to false, API will only be accessible within this VPC.
  # Specifically, kubectl commands will only work within this VPC.
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = data.aws_ami.ubuntu.image_type
  }

  # With Amazon EKS managed node groups, you don't need to separately provision or register the Amazon EC2 instances that provide compute capacity to run your Kubernetes applications
  # Every managed node is provisioned as part of an Amazon EC2 Auto Scaling group that's managed for you by Amazon EKS. 
  # Every resource including the instances and Auto Scaling groups runs within your AWS account. 
  # Each node group runs across multiple Availability Zones that you define.
  eks_managed_node_groups = {

    blue = {}
    green = {
      
      name =  "${var.project_id}-OnDemand-NodeGroup"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
      # We could make another nodegroup of spot instances if we wanted.
      capacity_type  = "ON_DEMAND"
    }
  }

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = false
  create_node_security_group    = false

  fargate_profile_defaults = {
    iam_role_additional_policies = {
      additional = aws_iam_policy.additional.arn
    }
  }

  # Create a Fargate profile to specify which Pods use Fargate when launched.
  fargate_profiles = merge(
    # We create a profile for each availability zone to evenly evenly spread pods across the AZs.
    { for i in range(length(data.availability_zones.available)) :
      # Fargate profile for the application
      "app-${element(split("-", data.availability_zones.available[i]), 2)}" = {
        selectors = [
          {
            # All pods in the app namespace will run on fargate.
            namespace = "app"
          }
        ]

        # Amazon EKS and Fargate spread Pods across each of the subnets that's defined in the Fargate profile. 
        # However, you might end up with an uneven spread. 
        # If you must have an even spread, use two Fargate profiles. 
        # Even spread is important in scenarios where you want to deploy two replicas and don't want any downtime. 
        # We recommend that each profile has only one subnet.
        subnet_ids = [element(data.aws_subnets.private_subnets, i)]

        tags = {
          Owner = "${var.project_id}-Application-FargateProfile"
        }

        timeouts = {
          create = "20m"
          delete = "20m"
        }
      },
      # Pods in the "kube-system" namespace will run on Fargate in the kube-system-x fargate profile
      # Where is the name of the availability zone e.g. kube-system-ap-south-1a
      "kube-system-${element(split("-", data.availability_zones.available[i]), 2)}" => {
        selectors = [
          { namespace = "kube-system" }
        ]
        # We want to create a profile per AZ for high availability
        subnet_ids = [element(data.aws_subnets.private_subnets, i)]
      }
    }
}