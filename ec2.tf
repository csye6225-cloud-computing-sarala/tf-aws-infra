# Create EC2 Instance
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

  # Database connection details
  DB_HOST="${aws_db_instance.postgres_instance.address}"
  DB_USER="${var.db_username}"
  DB_PASSWORD="${var.db_password}"
  DB_NAME="${var.db_name}"

  # Store environment variables globally
  echo "DB_HOST=$DB_HOST" | sudo tee -a /etc/environment
  echo "DB_USER=$DB_USER" | sudo tee -a /etc/environment
  echo "DB_PASSWORD=$DB_PASSWORD" | sudo tee -a /etc/environment
  echo "DB_NAME=$DB_NAME" | sudo tee -a /etc/environment

  # Update the .env file for the application
  sudo tee /opt/csye6225/monil_shah_002824667_04/.env <<EOL
  PROD_DB_USER=$DB_USER
  PROD_DB_HOST=$DB_HOST
  PROD_DB_NAME=$DB_NAME
  PROD_DB_PASSWORD=$DB_PASSWORD
  PROD_DB_PORT=5432
  PROD_PORT=8080
  DB_DIALECT=postgres
  PORT=8080
  EOL

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
