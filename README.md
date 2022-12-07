# Terraform Experiments

## Experiments

- [x] 1. [**Static Website**](/1-StaticWebsite) Route 53 -> Cloudfront -> S3 Website
- [x] 2. [**API Gateway**](2-ApiGateway) Route 53 -> Api Gateway (Edge) -> Existing API
- [ ] 3. **Simple Service** Route 53 -> Api Gateway (Edge) -> EC2
- [ ] 4. **LoadBalanced Service** Route 53 -> Api Gateway (Edge) -> ELB -> EC2 
- [ ] 5. **LoadBalanced Data Service (VPC)** Route 53 -> Api Gateway (Edge) -> ELB -> EC2 -> RDS
- [ ] 6. **ECS Cluster (VPC)** Route 53 -> Api Gateway (Edge) -> ELB -> ECS -> RDS
- [ ] 7. **EKS Cluster (VPC)** Route 53 -> Api Gateway (Edge) -> ELB -> EKS -> RDS

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


## Required IAM Permissions:

To use S3 as Backend:
```
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
[Terraform S3 Backend](https://www.terraform.io/docs/language/settings/backends/s3.html)