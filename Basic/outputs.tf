# List all outputs: terraform output
# Get specific output (wrapped in quotes): terraform output instance_public_ip
# Get specific output (without quotes): terraform output -raw instance_public_ip
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.example.id
  # sensitive = true (for sensitive data)
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.example.public_ip
}