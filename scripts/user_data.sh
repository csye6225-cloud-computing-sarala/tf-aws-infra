#!/bin/bash
# Install updates and dependencies
sudo apt-get update
sudo apt-get install -y postgresql-client curl

# Database connection details
DB_HOST="${aws_db_instance.postgres_instance.address}"
DB_USER="${var.db_username}"
DB_PASSWORD="${var.db_password}"
DB_NAME="${var.db_name}"

# AWS credentials (from dev.tfvars or environment variables)
AWS_ACCESS_KEY_ID="${var.aws_access_key_id}"
AWS_SECRET_ACCESS_KEY="${var.aws_secret_access_key}"
AWS_REGION="us-east-1"
S3_BUCKET="${aws_s3_bucket.bucket}"

# Store environment variables globally
echo "DB_HOST=$DB_HOST" | sudo tee -a /etc/environment
echo "DB_USER=$DB_USER" | sudo tee -a /etc/environment
echo "DB_PASSWORD=$DB_PASSWORD" | sudo tee -a /etc/environment
echo "DB_NAME=$DB_NAME" | sudo tee -a /etc/environment
echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" | sudo tee -a /etc/environment
echo "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" | sudo tee -a /etc/environment
echo "AWS_REGION=$AWS_REGION" | sudo tee -a /etc/environment
echo "S3_BUCKET=$S3_BUCKET" | sudo tee -a /etc/environment

# Update the .env file for the application
sudo tee /var/www/webapp/.env <<EOL
PROD_DB_USER=$DB_USER
PROD_DB_HOST=$DB_HOST
PROD_DB_NAME=$DB_NAME
PROD_DB_PASSWORD=$DB_PASSWORD
PROD_DB_PORT=5432
DB_DIALECT=postgres
PORT=3000
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
AWS_REGION=$AWS_REGION
S3_BUCKET=$S3_BUCKET
EOL

sudo systemctl enable amazon-cloudwatch-agent

# Restart the application service
sudo systemctl restart csye6225.service

