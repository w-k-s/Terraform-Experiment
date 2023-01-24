# Terraform Experiments

## Experiments

- [x] 1. [**Static Website**](/1-StaticWebsite) Route 53 -> Cloudfront -> S3 Website
- [x] 2. [**API Gateway**](2-ApiGateway) Route 53 -> Api Gateway (Edge) -> Existing API
- [x] 3. [**Simple Service**](/3-SimpleService) Route 53 -> Api Gateway (Edge) -> EC2
- [ ] 4. [**LoadBalanced Service**](/4-LoadBalancedService) Route 53 -> Api Gateway (Edge) -> ELB -> EC2 
- [ ] 5. [**LoadBalanced Data Service**](/5-DataService) Route 53 -> VPC -> Api Gateway (Edge) -> ELB -> EC2 -> RDS
- [ ] 6. **ECS Cluster** Route 53 -> VPC -> Api Gateway (Edge) -> ELB -> ECS -> RDS
- [ ] 7. **EKS Cluster** Route 53 -> VPC -> Api Gateway (Edge) -> ELB -> EKS -> RDS

## Required Environment Variables

This project requires the following [Repository Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository) to be setup in Github Actions.

| Secret Name                | Description                                                                                                                                                                                           | Example Value          |
|----------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------|
| AWS_ACCESS_KEY_ID          | The Programmatic Access Key Id of the IAM User that will be used to deploy resources on AWS. The necessary IAM permissions are described below                                                        | N/A                    |
| AWS_SECRET_ACCESS_KEY      | The Programmatic Access Secret Key of the IAM user that will be used to deploy resources on AWS. The necessary IAM permissions are described below                                                    | N/A                    |
| AWS_REGION                 | The region in which the AWS resources will be deployed.                                                                                                                                               | `us-east-1`            |
| HOSTED_ZONE_NAME           | The Name of the Route 53 Hosted Zone in which the DNS records for the deployed websites/APIs will be added.                                                                                           | `example.io`           |
| NEUTRINO_USER_ID           | `2-ApiGateway` proxies to Neutrino's `convert` API. Create an account with [`NeutrinoAPI`](https://www.neutrinoapi.com/signup/) with a user-id of your choice and provide this user id in the secret. | `my-user-id`           |
| NEUTRINO_API_KEY           | `2-ApiGateway` proxies to Neutrino's `convert` API. Use the `testing` API key generated when you created an account with `Neutrino API`                                                               | N/A                    |
| STATIC_WEBSITE_BUCKET_NAME | For `1-StaticWebsite`, this is the bucket in which the source code of the static website is saved. I believe this bucket should have the same name as the value `STATIC_WEBSITE_HOST`                 | `terraform.example.io` |
| STATIC_WEBSITE_HOST        | For `1-StaticWebsite`, this is the host name at which the static website will be hosted.                                                                                                              | `terraform.example.io` |
| API_GATEWAY_HOST           | For `2-ApiGateway`, this is the host name at which the API will be hosted                                                                                                                             | `api.example.io`       |
| SIMPLE_SERVICE_HOST        | For `3-SimpleService`, this is the host name at which the API will be hosted                                                                                                                          | `todo.example.io`      |
| LOAD_BALANCED_SERVICE_HOST| For `4-LoadBalancedService`, this is the host name at which the API will be hosted                                                                                                                          | `measurements.example.io`      |


## Required IAM Permissions:

To use S3 as Backend:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::mybucket"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::mybucket/path/to/my/key"
    }
  ]
}

```
- [Reference: Terraform S3 Backend](https://www.terraform.io/docs/language/settings/backends/s3.html)


The IAM policy used by the terraform user (that runs these experiments):
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:*",
                "appmesh:*",
                "application-autoscaling:*",
                "route53:*",
                "acm:*",
                "route53domains:*",
                "cloudfront:*",
                "cloudformation:*",
                "elasticloadbalancing:*",
                "ec2:*",
                "ecr:*",
                "ecs:*",
                "events:*",
                "elasticfilesystem:*",
                "codedeploy:*",
                "logs:*",
                "cloudwatch:*",
                "cloudtrail:*",
                "cloudfront:*",
                "lambda:*",
                "route53:*",
                "servicediscovery:*",
                "sns:ListTopics",
                "waf:ListWebACLs",
                "waf:GetWebACL",
                "wafv2:ListWebACLs",
                "wafv2:GetWebACL"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "apigateway:*"
            ],
            "Resource": "arn:aws:apigateway:*::/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "replication.ecr.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Action": [
                "kinesis:ListStreams",
                "kinesis:DescribeStream"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:kinesis:*:*:*"
        },
        {
            "Action": [
                "iam:*"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:iam::*:*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "autoscaling.amazonaws.com",
                        "ec2scheduled.amazonaws.com",
                        "elasticloadbalancing.amazonaws.com",
                        "spot.amazonaws.com",
                        "spotfleet.amazonaws.com",
                        "transitgateway.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws:iam::*:role/aws-service-role/acm.amazonaws.com/AWSServiceRoleForCertificateManager*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "acm.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:DeleteServiceLinkedRole",
                "iam:GetServiceLinkedRoleDeletionStatus",
                "iam:GetRole"
            ],
            "Resource": "arn:aws:iam::*:role/aws-service-role/acm.amazonaws.com/AWSServiceRoleForCertificateManager*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:GetParametersByPath"
            ],
            "Resource": "arn:aws:ssm:*:*:parameter/aws/service/ecs*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteInternetGateway",
                "ec2:DeleteRoute",
                "ec2:DeleteRouteTable",
                "ec2:DeleteSecurityGroup"
            ],
            "Resource": [
                "*"
            ],
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/aws:cloudformation:stack-name": "EC2ContainerService-*"
                }
            }
        },
        {
            "Action": "iam:PassRole",
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Condition": {
                "StringLike": {
                    "iam:PassedToService": "ecs-tasks.amazonaws.com"
                }
            }
        },
        {
            "Action": "iam:PassRole",
            "Effect": "Allow",
            "Resource": [
                "arn:aws:iam::*:role/ecsInstanceRole*"
            ],
            "Condition": {
                "StringLike": {
                    "iam:PassedToService": [
                        "ec2.amazonaws.com",
                        "ec2.amazonaws.com.cn"
                    ]
                }
            }
        },
        {
            "Action": "iam:PassRole",
            "Effect": "Allow",
            "Resource": [
                "arn:aws:iam::*:role/ecsAutoscaleRole*"
            ],
            "Condition": {
                "StringLike": {
                    "iam:PassedToService": [
                        "application-autoscaling.amazonaws.com",
                        "application-autoscaling.amazonaws.com.cn"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": [
                        "autoscaling.amazonaws.com",
                        "ecs.amazonaws.com",
                        "ecs.application-autoscaling.amazonaws.com",
                        "spot.amazonaws.com",
                        "spotfleet.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
```
- *Don't count on me to update the IAM policy above*
- **TODO**: Figure out the minimum set of permissions for each experiment. [This article](https://meirg.co.il/2021/04/23/determining-aws-iam-policies-according-to-terraform-and-aws-cli/) describes how it can be done using [iamlive](https://github.com/iann0036/iamlive) by [Ian Mckay](https://github.com/iann0036).