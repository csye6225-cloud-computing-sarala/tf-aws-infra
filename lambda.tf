# SNS Topic for User Signup Notifications
resource "aws_sns_topic" "user_registration_topic" {
  name = "user-registration-topic"
}

# Lambda Function Resource
resource "aws_lambda_function" "send_verification_email" {
  filename         = "${path.module}/lambda_function.zip"
  function_name    = "EmailVerificationFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "handler.handler" # Update with your handler
  runtime          = "nodejs18.x"
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")

  environment {
    variables = {
      EMAIL_SECRET_ID = aws_secretsmanager_secret.email_service_credentials.name
    }
  }
}
