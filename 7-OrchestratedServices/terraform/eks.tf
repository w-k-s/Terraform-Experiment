locals {
  cluster_name = "${var.project_id}-Cluster"
}

data "aws_caller_identity" "current" {}

data "aws_kms_key" "by_key_arn" {
  # Not ideal but okay for now.
  key_id = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.current.account_id}:key/c8bd1d18-0cef-47aa-bad9-365d285c84fb"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = local.cluster_name
  cluster_version = "1.27"
  cluster_endpoint_public_access = true

  vpc_id                         = aws_default_vpc.this.id
  subnet_ids                     = data.aws_subnets.private_subnets.ids

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

  create_kms_key = false
  cluster_encryption_config = {}

  eks_managed_node_group_defaults = {
    disk_size                  = 20
    
    instance_types = ["t3.small"]
    ami_type       = "AL2_x86_64"
    # We are using the IRSA created below for permissions
    # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
    # and then turn this off after the cluster/node group is created. Without this initial policy,
    # the VPC CNI fails to assign IPs and nodes cannot join the cluster
    # See https://github.com/aws/containers-roadmap/issues/1666 for more context
    iam_role_attach_cni_policy = true
    iam_role_additional_policies = {
      additional_ecr_access = aws_iam_policy.additional_ecr_access.id
    }
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

resource "aws_iam_policy" "additional_ecr_access" {
  name        = "ecr-read-access"
  description = "Allow ECR access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : [
          "ecr:GetRegistryPolicy",
          "ecr:DescribeImageScanFindings",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeRegistry",
          "ecr:DescribePullThroughCacheRules",
          "ecr:DescribeImageReplicationStatus",
          "ecr:GetAuthorizationToken",
          "ecr:ListTagsForResource",
          "ecr:ListImages",
          "ecr:BatchGetRepositoryScanningConfiguration",
          "ecr:GetRegistryScanningConfiguration",
          "ecr:GetAuthorizationToken*",
          "ecr:UntagResource",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:TagResource",
          "ecr:DescribeRepositories",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetRepositoryPolicy",
          "ecr:GetLifecyclePolicy"
        ]
      }
    ]
  })
}