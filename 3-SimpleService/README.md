# Simple Service

## TODO

- [ ] Add end-to-end tests
- [ ] Push application logs to cloudwatch
- [ ] Use template file to pass user-data shell script. Pass region, bucket name and jar name through the template file.

## Future enhancements

- [ ] Auto redirect HTTP to HTTPS
- [ ] Configure AWS API Gateway to return 404 instead of `{"message":"Missing Authentication Token"}` on `curl https://todo.w-k-s.io`
- [ ] Configure apache2 to not display address in default 404.html `<address>Apache/2.4.41 (Ubuntu) Server at localhost Port 80</address>`  

## Useful Resources

- [Deploy a set of EC2 instances behind an alb using terraform](https://aws.plainenglish.io/deploy-a-set-of-ec2-instances-behind-an-alb-using-terraform-403fe584f09e)
-[Cloudwatch Agent on EC2 with Terraform](https://jazz-twk.medium.com/cloudwatch-agent-on-ec2-with-terraform-8cf58e8736de)
- [How to send log files to AWS Cloudwatch Ubuntu](https://www.rapidspike.com/blog/how-to-send-log-files-to-aws-cloudwatch-ubuntu/)