# IAM Role for Lambda Function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "lambda.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

# IAM Policy Attachment for Lambda
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# IAM Policy for Lambda Function
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_execution_policy"
  description = "IAM policy for Lambda execution"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource : "arn:aws:logs:*:*:*"
      },
      # {
      #   Effect : "Allow",
      #   Action : [
      #     "ses:SendEmail",
      #     "ses:SendRawEmail"
      #   ],
      #   Resource : "*"
      # },
      {
        Effect : "Allow",
        Action : [
          "rds:DescribeDBInstances"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "sns:Publish"
        ],
        Resource : aws_sns_topic.user_registration_topic.arn
      },
      {
        Effect : "Allow",
        Action : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource : [
          aws_secretsmanager_secret.db_credentials.arn,
          aws_secretsmanager_secret.email_config.arn,
          aws_secretsmanager_secret.mailgun_credentials.arn
        ]
      },
      # SSM permissions (if using SSM)
      {
        Effect : "Allow",
        Action : [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ],
        Resource : [
          "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/lambda/*"
        ]
      },
      # # SNS permissions (if Lambda needs to publish messages)
      # {
      #   Effect : "Allow",
      #   Action : [
      #     "sns:Publish"
      #   ],
      #   Resource : aws_sns_topic.user_registration_topic.arn
      # },
      # VPC permissions (if Lambda is in a VPC)
      {
        Effect : "Allow",
        Action : [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource : "*"
      }
    ]
  })
}

# Lambda Function Resource
resource "aws_lambda_function" "email_verification_function" {
  filename         = "${path.module}/lambda_function.zip" # Update with your zip file path
  function_name    = "EmailVerificationFunction"
  role             = aws_iam_role.lambda_role.arn
  handler          = "handler.handler" # Update with your handler
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")
  runtime          = "nodejs18.x"

  environment {
    variables = {
      SNS_TOPIC_ARN      = aws_sns_topic.user_registration_topic.arn
      DB_HOST            = var.db_host
      DB_USER            = var.db_username
      DB_PASSWORD_SECRET = aws_secretsmanager_secret.db_credentials.arn
      DB_NAME            = var.db_name
      DB_PORT            = var.db_port
      AWS_REGION         = var.aws_region
      EMAIL_SENDER       = var.email_sender
      MAILGUN_SECRET_ARN = aws_secretsmanager_secret.mailgun_credentials.arn
      MAILGUN_DOMAIN     = var.mailgun_domain
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnets
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attachment]
}

# Data Source to Retrieve Current AWS Account Information
data "aws_caller_identity" "current" {}
