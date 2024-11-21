# SNS Topic for User Signup Notifications
resource "aws_sns_topic" "user_registration_topic" {
  name = "user-registration-topic"
}


# IAM Role for Lambda Function
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : { Service : "lambda.amazonaws.com" },
        Effect : "Allow"
      }
    ]
  })
}

# Lambda Function Resource
resource "aws_lambda_function" "send_verification_email" {
  filename         = "${path.module}/lambda_function.zip" # Update with your zip file path
  function_name    = "EmailVerificationFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "handler.handler" # Update with your handler
  runtime          = "nodejs18.x"
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")

  environment {
    variables = {
      MAILGUN_SECRET_ARN = aws_secretsmanager_secret.mailgun_credentials.arn
      MAILGUN_DOMAIN     = var.mailgun_domain
    }
  }
}
