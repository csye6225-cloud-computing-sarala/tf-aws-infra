output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

# Output the public IP of the EC2 instance
output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app_instance.public_ip
}

# Output the instance ID of the EC2 instance
output "instance_id" {
  description = "Instance ID of the EC2 instance"
  value       = aws_instance.app_instance.id
}
