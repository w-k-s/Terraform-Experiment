# Terraform Experiments

## Experiments

- [x] 1. [**Static Website**](/1-StaticWebsite) Route 53 -> Cloudfront -> S3 Website
- [ ] 2. [**API Gateway**](2-ApiGateway) Route 53 -> Api Gateway (Edge) -> Existing API
- [ ] 3. **Simple Service** Route 53 -> Api Gateway (Edge) -> EC2
- [ ] 4. **LoadBalanced Service** Route 53 -> Api Gateway (Edge) -> ELB -> EC2 
- [ ] 5. **LoadBalanced Data Service (VPC)** Route 53 -> Api Gateway (Edge) -> ELB -> EC2 -> RDS
- [ ] 6. **ECS Cluster (VPC)** Route 53 -> Api Gateway (Edge) -> ELB -> ECS -> RDS
- [ ] 7. **EKS Cluster (VPC)** Route 53 -> Api Gateway (Edge) -> ELB -> EKS -> RDS

## Required Environment Variables:

- `AWS_ACCESS_KEY_ID` (or `~/.aws/credentials`)
- `AWS_SECRET_ACCESS_KEY` (or `~/.aws/credentials`)


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