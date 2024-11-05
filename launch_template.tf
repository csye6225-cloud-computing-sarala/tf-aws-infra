# Launch Template
resource "aws_launch_template" "app_launch_template" {
  name          = "csye6225_asg"
  image_id      = var.ami_id
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
# Stop services if running
# sudo systemctl stop amazon-cloudwatch-agent || true
# sudo systemctl stop csye6225.service || true

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
sudo tee -a /etc/environment <<EOL
DB_HOST=$DB_HOST
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_NAME=$DB_NAME
AWS_REGION=$AWS_REGION
S3_BUCKET=$S3_BUCKET
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
EOL

# # Update CloudWatch Agent configuration
# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 \
#   -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# Download and install CloudWatch Agent
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O amazon-cloudwatch-agent.deb
    sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
 
    # Fetch the InstanceId for CloudWatch dimension
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
 
    # Create CloudWatch Agent configuration with InstanceId as a dimension
    cat <<'CONFIG' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    {
      "agent": {
          "metrics_collection_interval": 10,
          "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
      },
      "logs": {
          "logs_collected": {
              "files": {
                  "collect_list": [
                      {
                          "file_path": "/var/log/syslog",
                          "log_group_name": "EC2AppLogs",
                          "log_stream_name": "syslog",
                          "timestamp_format": "%b %d %H:%M:%S"
                      },
                      {
                          "file_path": "/opt/webapp/logs/app.log",
                          "log_group_name": "EC2AppLogs",
                          "log_stream_name": "app_log",
                          "timestamp_format": "%Y-%m-%dT%H:%M:%S.%LZ"
                      }
                  ]
              }
          }
      },
      "metrics": {
        "append_dimensions": {
          "InstanceId": "$INSTANCE_ID"
        },
        "metrics_collected": {
          "statsd": {
            "service_address": ":8125",
            "metrics_collection_interval": 15,
            "metrics_aggregation_interval": 300
          },
          "disk": {
            "resources": ["/"],
            "measurement": ["used_percent"],
            "metrics_collection_interval": 60
          },
          "mem": {
            "measurement": ["mem_used_percent"],
            "metrics_collection_interval": 60
          }
        }
      }
    }
    CONFIG
 
    # Start CloudWatch Agent with configuration
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
        -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# # Reload systemd daemon
# sudo systemctl daemon-reload

# # Enable and start the services
sleep 5
# nohup sudo systemctl restart csye6225.service &
# sleep 5
# nohup sudo systemctl restart amazon-cloudwatch-agent &

# # Check the status of the services
# sudo systemctl status amazon-cloudwatch-agent --no-pager
# sudo systemctl status csye6225.service --no-pager

# sleep 5
sudo systemctl restart csye6225.service
sleep 5
sudo systemctl restart amazon-cloudwatch-agent

EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "AppInstance"
    }
  }
}
