## Architecture

- The Load Balancer sits in front of EC2 instances and only handles HTTP traffic from the API Gateway
- There is no load balancer in front of the API Gateway because the API Gateway "will automatically scale to handle the amount of traffic your API receives" [(Q: How do APIs scale)](https://aws.amazon.com/api-gateway/faqs/)

## Useful Resources

- [Create the application load balancer](https://hiveit.co.uk/techshop/terraform-aws-vpc-example/04-create-the-application-load-balancer/)
- [Create Web Server Instances](https://hiveit.co.uk/techshop/terraform-aws-vpc-example/06-create-web-server-instances/)