## Required Environment Variables:

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