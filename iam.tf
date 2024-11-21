# IAM Role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role_v3"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
  tags = {
    "Name" = "ec2-iam-role"
  }
}

resource "aws_iam_policy" "custom_cloudwatch_policy" {
  name        = "CustomCloudWatchPolicy"
  description = "Allows EC2 to push custom metrics to CloudWatch"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "cloudwatch:PutMetricData"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach the policy to the EC2 IAM role
resource "aws_iam_role_policy_attachment" "custom_cloudwatch_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.custom_cloudwatch_policy.arn

}

# Policy document for S3 access
data "aws_iam_policy_document" "policy_document" {
  version = "2012-10-17"
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.s3_bucket.arn}",
      "${aws_s3_bucket.s3_bucket.arn}/*"
    ]
  }
  depends_on = [aws_s3_bucket.s3_bucket]
}

# Attach S3 policy to EC2 role
resource "aws_iam_role_policy" "s3_policy" {
  name       = "tf-s3-policy"
  role       = aws_iam_role.ec2_role.id
  policy     = data.aws_iam_policy_document.policy_document.json
  depends_on = [aws_s3_bucket.s3_bucket]
}

# IAM Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_instance_profile_v3"
  role = aws_iam_role.ec2_role.name
}

# IAM Policy for Lambda Function
resource "aws_iam_policy" "lambda_policy" {
  name        = "LambdaExecutionPolicy"
  description = "IAM policy for Lambda execution"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      # Allow Lambda to write logs
      {
        Effect : "Allow",
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource : "arn:aws:logs:*:*:*"
      },
      # Allow Lambda to retrieve secrets from Secrets Manager
      {
        Effect : "Allow",
        Action : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource : aws_secretsmanager_secret.mailgun_credentials.arn
      }
    ]
  })
}

# Attach the policy to the Lambda role
resource "aws_iam_role_policy_attachment" "attach_lambda_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# IAM Policy to allow EC2 instances to publish to SNS topic
resource "aws_iam_policy" "sns_publish_policy" {
  name        = "SNSPublishPolicy"
  description = "Policy to allow EC2 instances to publish to SNS topic"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : "sns:Publish",
        Resource : aws_sns_topic.user_registration_topic.arn
      }
    ]
  })
}

# Attach the policy to the EC2 role
resource "aws_iam_role_policy_attachment" "sns_publish_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.sns_publish_policy.arn
}
