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
  subnet_ids                     = data.aws_subnets.private_subnets.ids

  # Indicates whether or not the Amazon EKS public API server endpoint is enabled
  # If set to false, API will only be accessible within this VPC.
  # Specifically, kubectl commands will only work within this VPC.
  cluster_endpoint_public_access = true
  # Controls if a KMS key for cluster encryption should be created
  # Disabled because it was giving me trouble. Hopefully, I'll get back to this when I'm wiser.
  create_kms_key = false
  # If you set `create_kms_key` to false, you also neeed to set cluster_encryption_config to {}
  # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2321#issuecomment-1340214864
  cluster_encryption_config = {}
  # kms_key_administrators = [
  #   put admin IAM ARN here. 
  # ]

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
  }

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.small"]
    disk_size                  = 20
    # We are using the IRSA created below for permissions
    # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
    # and then turn this off after the cluster/node group is created. Without this initial policy,
    # the VPC CNI fails to assign IPs and nodes cannot join the cluster
    # See https://github.com/aws/containers-roadmap/issues/1666 for more context
    iam_role_attach_cni_policy = true
  }

  # With Amazon EKS managed node groups, you don't need to separately provision or register the Amazon EC2 instances that provide compute capacity to run your Kubernetes applications
  # Every managed node is provisioned as part of an Amazon EC2 Auto Scaling group that's managed for you by Amazon EKS. 
  # Every resource including the instances and Auto Scaling groups runs within your AWS account. 
  # Each node group runs across multiple Availability Zones that you define.
  eks_managed_node_groups = {

    # blue = {}
    green = {
      
      name =  "${var.project_id}-OnDemand"
      use_name_prefix = false # Use name as-is, not as a prefix.
      min_size     = 1
      max_size     = 3
      desired_size = 1
      subnet_ids   = data.aws_subnets.private_subnets.ids
      # We could make another nodegroup of spot instances if we wanted.
      capacity_type  = "ON_DEMAND"
    }
  }
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  # one of vpc_cni_enable_ipv6 or vpc_cni_enable_ipv4 is required (when attach_vpc_cni_policy is true)
  vpc_cni_enable_ipv6   = true 

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}