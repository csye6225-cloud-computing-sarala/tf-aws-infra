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
# output "ec2_public_ip" {
#   description = "Public IP of the EC2 instance"
#   value       = aws_instance.app_instance.public_ip
# }

# # Output the instance ID of the EC2 instance
# output "ec2_instance_id" {
#   description = "Instance ID of the EC2 instance"
#   value       = aws_instance.app_instance.id
# }

output "rds_endpoint" {
  description = "RDS endpoint to connect to the database"
  value       = aws_db_instance.postgres_instance.endpoint
}

output "rds_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.postgres_instance.id
}

output "app_instance_public_ip" {
  description = "Public IP of the App EC2 Instance in the specified environment"
  value       = aws_instance.app_instance.public_ip
}

output "app_instance_environment" {
  description = "Current environment of the App Instance (dev or demo)"
  value       = var.environment
}

output "s3_bucket_name" {
  description = "Name of the created S3 Bucket"
  value       = aws_s3_bucket.s3_bucket.bucket
}

output "root_zone_id" {
  description = "Route53 Hosted Zone ID for the Root Domain"
  value       = data.aws_route53_zone.selected.zone_id
}
