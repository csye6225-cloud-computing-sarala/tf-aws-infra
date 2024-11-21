# Allow SNS to invoke the Lambda function
resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_verification_email.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_registration_topic.arn
}

# SNS Subscription to the Lambda function
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.user_registration_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.send_verification_email.arn
}
