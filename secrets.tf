locals {
  unique_id = uuid()
}
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "db_credentials__${local.unique_id}"
  description = "Database credentials for Lambda function"
  kms_key_id  = aws_kms_key.secrets_kms_key.arn
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    DB_HOST     = aws_db_instance.postgres_instance.address
    DB_USER     = aws_db_instance.postgres_instance.username
    DB_PASSWORD = random_password.db_password.result
    DB_NAME     = aws_db_instance.postgres_instance.db_name
    DB_PORT     = aws_db_instance.postgres_instance.port
  })
  depends_on = [aws_db_instance.postgres_instance]
}

resource "aws_secretsmanager_secret" "email_config" {
  name        = "email_config__${local.unique_id}"
  description = "Email configuration for Lambda function"
}

resource "aws_secretsmanager_secret_version" "email_config_version" {
  secret_id = aws_secretsmanager_secret.email_config.id
  secret_string = jsonencode({
    EMAIL_SENDER = var.email_sender
  })
}

# Secrets Manager Secret for Mailgun API Key
resource "aws_secretsmanager_secret" "mailgun_credentials" {
  name = "mailgun_credentials_${local.unique_id}"
}

# Secret value (the API key)
resource "aws_secretsmanager_secret_version" "mailgun_credentials_version" {
  secret_id = aws_secretsmanager_secret.mailgun_credentials.id
  secret_string = jsonencode({
    MAILGUN_API_KEY = var.mailgun_api_key
  })
}

# Generate a Random Password
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*+-=?^_`{|}~"
}

# Create Secrets Manager Secret for DB Password
resource "aws_secretsmanager_secret" "db_password_secret" {
  name        = "db-password-secret_${local.unique_id}"
  description = "Database password"
  kms_key_id  = aws_kms_key.secrets_kms_key.arn
}

# Store the Password in Secrets Manager
resource "aws_secretsmanager_secret_version" "db_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_password_secret.id
  secret_string = jsonencode({ password = random_password.db_password.result })
}

# Create Secrets Manager Secret for Email Service
resource "aws_secretsmanager_secret" "email_service_credentials" {
  name        = "email-service-credentials_${local.unique_id}"
  description = "Email service credentials"
  kms_key_id  = aws_kms_key.secrets_kms_key.arn
}

# Store the Credentials in Secrets Manager
resource "aws_secretsmanager_secret_version" "email_service_credentials_version" {
  secret_id = aws_secretsmanager_secret.email_service_credentials.id
  secret_string = jsonencode({
    MAILGUN_API_KEY = var.mailgun_api_key
    MAILGUN_DOMAIN  = var.mailgun_domain
  })
}
