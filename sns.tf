resource "aws_sns_topic" "user_registration_topic" {
  name = "user-registration-topic"
}

# Optional: Output the SNS topic ARN
output "sns_topic_arn" {
  value = aws_sns_topic.user_registration_topic.arn
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.user_registration_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.email_verification_function.arn
}

# Allow SNS to invoke Lambda
resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_verification_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_registration_topic.arn
}
