# Define the RDS Instance for PostgreSQL
resource "aws_db_instance" "postgres_instance" {
  identifier             = "csye6225"
  allocated_storage      = var.db_allocated_storage
  storage_type           = var.db_storage_type
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.db_password.result
  parameter_group_name   = aws_db_parameter_group.postgresql_param_group.name
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false
  apply_immediately      = true
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds_kms_key.arn

  tags = {
    Name = "csye6225-postgresql"
  }
}

# Define the RDS Parameter Group for PostgreSQL
resource "aws_db_parameter_group" "postgresql_param_group" {
  name        = "csye6225-postgresql-param-group"
  family      = var.db_parameter_group_family
  description = "Custom parameter group for csye6225 PostgreSQL RDS instance"

  parameter {
    name         = "max_connections"
    value        = "150"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "log_statement"
    value        = "all"
    apply_method = "pending-reboot"
  }

  tags = {
    Name = "csye6225-postgresql-param-group"
  }
}

# Define the RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name = "main-db-subnet-group"
  subnet_ids = [
    aws_subnet.private[0].id,
    aws_subnet.private[1].id,
    aws_subnet.private[2].id
  ]

  tags = {
    Name = "main-db-subnet-group"
  }
}
