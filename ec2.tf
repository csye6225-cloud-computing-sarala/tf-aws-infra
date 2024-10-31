resource "aws_instance" "app_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  # User data script with variable interpolation
  user_data = <<-EOF
#!/bin/bash -ex
# Install updates and dependencies
sudo apt-get update
sudo apt-get install -y postgresql-client curl

# Database connection details
DB_HOST="${aws_db_instance.postgres_instance.address}"
DB_USER="${var.db_username}"
DB_PASSWORD="${var.db_password}"
DB_NAME="${var.db_name}"
AWS_REGION="${var.aws_region}"
S3_BUCKET="${aws_s3_bucket.s3_bucket.bucket}"

# Store environment variables globally
echo "DB_HOST=$DB_HOST" | sudo tee -a /etc/environment
echo "DB_USER=$DB_USER" | sudo tee -a /etc/environment
echo "DB_PASSWORD=$DB_PASSWORD" | sudo tee -a /etc/environment
echo "DB_NAME=$DB_NAME" | sudo tee -a /etc/environment
echo "AWS_REGION=$AWS_REGION" | sudo tee -a /etc/environment
echo "S3_BUCKET=$S3_BUCKET" | sudo tee -a /etc/environment

# Update the .env file for the application
sudo tee /var/www/webapp/.env > /dev/null <<EOL
PROD_DB_USER=$DB_USER
PROD_DB_HOST=$DB_HOST
PROD_DB_NAME=$DB_NAME
PROD_DB_PASSWORD=$DB_PASSWORD
PROD_DB_PORT=5432
DB_DIALECT=postgres
PORT=3000
AWS_REGION=$AWS_REGION
S3_BUCKET=$S3_BUCKET
EOL

# Update CloudWatch Agent configuration
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a stop
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# Restart the application service and ensure it's running
sleep 5
nohup sudo systemctl restart csye6225.service &

# Restart CloudWatch Agent with a delay to ensure it's fully stopped
sleep 5
nohup sudo systemctl restart amazon-cloudwatch-agent &


# Verify status of services after restart
sudo systemctl status amazon-cloudwatch-agent
sudo systemctl status csye6225.service
sudo systemctl restart csye6225.service
sudo systemctl restart amazon-cloudwatch-agent
EOF

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "AppInstance"
  }
}
