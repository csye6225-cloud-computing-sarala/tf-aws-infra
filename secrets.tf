locals {
  unique_id = uuid()
}
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "db_credentials__${local.unique_id}"
  description = "Database credentials for Lambda function"
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    DB_HOST     = var.db_host
    DB_USER     = var.db_username
    DB_PASSWORD = var.db_password
    DB_NAME     = var.db_name
    DB_PORT     = var.db_port
  })
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
