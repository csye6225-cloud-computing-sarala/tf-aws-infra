# Create EC2 Instance
resource "aws_instance" "app_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  # User Data Script to configure the web application with database info
  user_data = <<-EOF
    #!/bin/bash
    # Install updates and dependencies
    sudo apt-get update
    sudo apt-get install -y postgresql-client curl

    # Database connection details
    DB_HOST="${aws_db_instance.postgres_instance.address}"
    DB_USER="${var.db_username}"
    DB_PASSWORD="${var.db_password}"
    DB_NAME="${var.db_name}"

    # Store environment variables
    echo "DB_HOST=$DB_HOST" >> /etc/environment
    echo "DB_USER=$DB_USER" >> /etc/environment
    echo "DB_PASSWORD=$DB_PASSWORD" >> /etc/environment
    echo "DB_NAME=$DB_NAME" >> /etc/environment

    # Example: Passing the database info to the application
    echo "DATABASE_URL=postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:5432/$DB_NAME" >> /var/www/app/.env

    # Start the application (assuming you have a start script)
    cd /var/www/webapp
    npm install
    npm run start
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
