# 2-ApiGateway


## IAM Permissions

I had to attach the following permissions to the policy
 attached to the terraform role.
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "acm:DeleteCertificate",
                "acm:DescribeCertificate",
                "acm:RequestCertificate",
                "acm:RemoveTagsFromCertificate",
                "acm:GetCertificate",
                "acm:AddTagsToCertificate",
                "acm:ListCertificates",
                "acm:ImportCertificate",
                "acm:RenewCertificate"
            ],
            "Resource": "*"
        }
    ]
}
```

