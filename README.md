# Terraform Experiments

## Experiments

- [x] 1. [**Static Website**](/1-StaticWebsite) Route 53 -> Cloudfront -> S3 Website
- [x] 2. [**API Gateway**](2-ApiGateway) Route 53 -> Api Gateway (Edge) -> Existing API
- [x] 3. [**Simple Service**](/3-SimpleService) Route 53 -> Api Gateway (Edge) -> EC2
- [x] 4. [**LoadBalanced Service**](/4-LoadBalancedService) Route 53 -> Api Gateway (Edge) -> ELB -> EC2 
- [x] 5. [**LoadBalanced Data Service**](/5-DataService) Route 53 -> Api Gateway (Edge) -> VPC Link -> ELB -> EC2 -> RDS
- [x] 6. [**ECS Cluster**](/6-ContainerizedServices) Route 53 -> Api Gateway (Edge) -> VPC Link -> ELB -> ECS -> RDS
- [ ] 7. **EKS Cluster** Route 53 -> Api Gateway (Edge) -> VPC Link -> ELB -> EKS -> RDS
- [ ] 8. [**Serverless Architecture**](/8-ServerlessArchitecture) Cloudfront -> Api Gateway (Edge) -> Lambda -> Supabase

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
| DATA_SERVICE_HOST| For `5-DataService`, this is the host name at which the API will be hosted                                                                                                                          | `noticeboard.example.io`      |
| CONTAINERIZED_APP_HOST| For `6-ContainerizedService`, this is the host name at which the API will be hosted                  | `taskmonkey.example.io`      |
| RDS_PSQL_INSTANCE_IDENTIFIER| The DB identifier of a RDS PostgreSQL instance                                                                                                                          | `my-postgresqldb-on-aws`      |
| RDS_PSQL_MASTER_USERNAME| The username to connect to the RDS PSQL instance. This role should eb able to create a database, create roles, and grant permissions                                                                                                                          | N/A      |
| RDS_PSQL_MASTER_PASSWORD| The password for the RDS master username provided earlier                                                                                                                         | N/A     |


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
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "cognito-identity:*",
                "cognito-idp:*"
            ],
            "Resource": [
                "arn:aws:cognito-identity:ap-south-1:838107339577:identitypool/*",
                "arn:aws:wafv2:ap-south-1:838107339577:*/webacl/*/*",
                "arn:aws:cognito-idp:ap-south-1:838107339577:userpool/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "waf:*",
                "rds:*",
                "wafv2:*",
                "kinesis:ListStreams",
                "route53domains:*",
                "apigateway:*",
                "cloudwatch:*",
                "ecs:*",
                "ec2:*",
                "sns:ListTopics",
                "elasticfilesystem:*",
                "s3:*",
                "kinesis:DescribeStream",
                "ssm:*",
                "ecr:*",
                "acm:*",
                "application-autoscaling:*",
                "logs:*",
                "autoscaling:*",
                "servicediscovery:*",
                "cloudfront:*",
                "events:*",
                "cloudformation:*",
                "iam:*",
                "cognito-idp:*",
                "cognito-identity:*",
                "codedeploy:*",
                "elasticloadbalancing:*",
                "route53:*",
                "lambda:*",
                "cognito-idp:ConfirmDevice"
            ],
            "Resource": "*"
        }
    ]
}
```
- *Don't count on me to update the IAM policy above*
- **TODO**: Figure out the minimum set of permissions for each experiment. [This article](https://meirg.co.il/2021/04/23/determining-aws-iam-policies-according-to-terraform-and-aws-cli/) describes how it can be done using [iamlive](https://github.com/iann0036/iamlive) by [Ian Mckay](https://github.com/iann0036).