# Define the RDS Instance for PostgreSQL
resource "aws_db_instance" "postgres_instance" {
  identifier             = "csye6225"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "13.16"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = aws_db_parameter_group.postgresql_param_group.name
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name = "csye6225-postgresql"
  }
}

# Define the RDS Parameter Group for PostgreSQL
resource "aws_db_parameter_group" "postgresql_param_group" {
  name        = "csye6225-postgresql-param-group"
  family      = "postgres13" # Make sure the family matches your PostgreSQL version
  description = "Custom parameter group for csye6225 PostgreSQL RDS instance"

  # Dynamic parameter (can be applied immediately)
  parameter {
    name         = "max_connections"
    value        = "150"
    apply_method = "pending-reboot"
  }

  # Static parameter (requires a reboot)
  parameter {
    name         = "log_statement"
    value        = "all"
    apply_method = "pending-reboot"
  }

  tags = {
    Name = "csye6225-postgresql-param-group"
  }
}


resource "aws_db_subnet_group" "main" {
  name = "main-db-subnet-group"
  subnet_ids = [
    aws_subnet.private[0].id, # Add only subnets in the correct VPC
    aws_subnet.private[1].id,
    aws_subnet.private[2].id
  ]

  tags = {
    Name = "main-db-subnet-group"
  }
}

