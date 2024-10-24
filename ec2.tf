resource "aws_instance" "app_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = <<-EOF
  #!/bin/bash
  # Install updates and dependencies
  sudo apt-get update
  sudo apt-get install -y postgresql-client curl

  # Ensure application directory exists
  sudo mkdir -p /var/www/webapp

  # Create a non-privileged user for the application
  sudo useradd -m -s /bin/bash appuser

  # Database connection details
  DB_HOST="${aws_db_instance.postgres_instance.address}"
  DB_USER="${var.db_username}"
  DB_PASSWORD="${var.db_password}"
  DB_NAME="${var.db_name}"

  # Update the .env file for the application
  sudo tee /var/www/webapp/.env <<EOL
  PROD_DB_USER=$DB_USER
  PROD_DB_HOST=$DB_HOST
  PROD_DB_NAME=$DB_NAME
  PROD_DB_PASSWORD=$DB_PASSWORD
  PROD_DB_PORT=5432
  DB_DIALECT=postgres
  PORT=3000
  EOL

  # Set proper ownership and permissions for the application directory and .env file
  sudo chown -R appuser:appuser /var/www/webapp
  sudo chmod -R 755 /var/www/webapp
  sudo find /var/www/webapp -type f -exec chmod 644 {} \;

  # Edit the systemd service file to include the non-privileged user
  sudo tee /etc/systemd/system/csye6225.service <<EOL
  [Unit]
  Description=CSYE6225 Web Application

  [Service]
  ExecStart=/usr/bin/node /var/www/webapp/src/server.js
  WorkingDirectory=/var/www/webapp
  Restart=always
  User=appuser

  [Install]
  WantedBy=multi-user.target
  EOL

  # Reload systemd to apply changes
  sudo systemctl daemon-reload

  # Restart the application service
  sudo systemctl restart csye6225.service

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
