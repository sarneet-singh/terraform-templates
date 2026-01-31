output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.example.id
}

output "instance_public_ip" {
  description = "Public IP of the instance (if assigned)"
  value       = aws_instance.example.public_ip
}

output "iam_role_name" {
  description = "IAM role attached to EC2"
  value       = aws_iam_role.ec2_role.name
}
