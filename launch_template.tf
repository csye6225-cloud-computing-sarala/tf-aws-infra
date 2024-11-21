# Launch Template
resource "aws_launch_template" "app_launch_template" {
  name          = "csye6225_asg"
  image_id      = var.ami_id
  depends_on    = [aws_db_instance.postgres_instance]
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    device_index                = 0
    subnet_id                   = aws_subnet.public[0].id
    security_groups             = [aws_security_group.app_sg.id]
    associate_public_ip_address = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.volume_size
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  user_data = base64encode(<<-EOF
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
SNS_TOPIC_ARN="${aws_sns_topic.user_registration_topic.arn}"
DOMAIN="${var.domain_name}"

# Store environment variables globally
sudo tee -a /etc/environment <<EOL
DB_HOST=$DB_HOST
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_NAME=$DB_NAME
AWS_REGION=$AWS_REGION
S3_BUCKET=$S3_BUCKET
SNS_TOPIC_ARN=$SNS_TOPIC_ARN
DOMAIN=$DOMAIN
EOL

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
SNS_TOPIC_ARN=$SNS_TOPIC_ARN
DOMAIN=$DOMAIN
EOL

# Ensure CloudWatch Agent configuration file exists
  if [ ! -f "/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json" ]; then
    echo "CloudWatch Agent configuration file not found."
    exit 1
  fi

  # Update CloudWatch Agent configuration and start the agent
  # sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 \
  #   -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# Reload systemd to pick up any changes
sudo systemctl daemon-reload

# Enable services to start on boot
sudo systemctl enable csye6225.service
sudo systemctl enable amazon-cloudwatch-agent

# Restart services to pick up new environment variables
sudo systemctl restart csye6225.service
sudo systemctl restart amazon-cloudwatch-agent

# Verify status of services
sudo systemctl status amazon-cloudwatch-agent --no-pager
sudo systemctl status csye6225.service --no-pager
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "AppInstance"
    }
  }
}
