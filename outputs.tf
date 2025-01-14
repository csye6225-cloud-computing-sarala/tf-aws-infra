output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "rds_endpoint" {
  description = "RDS endpoint to connect to the database"
  value       = aws_db_instance.postgres_instance.endpoint
}

output "rds_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.postgres_instance.id
}

output "app_instance_environment" {
  description = "Current environment of the App Instance (dev or demo)"
  value       = var.environment
}

output "s3_bucket_name" {
  description = "Name of the created S3 Bucket"
  value       = aws_s3_bucket.s3_bucket.bucket
}
