# IAM Role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role_v3"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    "Name" = "ec2-iam-role"
  }
}

resource "aws_iam_policy" "secretsmanager_access_policy" {
  name        = "EC2SecretsManagerAccessPolicy"
  description = "Policy to allow EC2 instances to access Secrets Manager"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource : aws_secretsmanager_secret.db_credentials.arn
      },
      {
        Effect : "Allow",
        Action : ["kms:Decrypt"],
        Resource : aws_kms_key.secrets_kms_key.arn
      }
    ]
  })
}

# Attach the policy to the EC2 role
resource "aws_iam_role_policy_attachment" "secretsmanager_access_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.secretsmanager_access_policy.arn
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

resource "aws_kms_key" "ec2_kms_key" {
  description             = "KMS key used for encrypting EBS volumes"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  deletion_window_in_days = 10

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow service-linked role use of the customer managed key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow attachment of persistent resources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:CreateGrant"
        ],
        "Resource" : "*",
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : true
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_kms_policy" {
  name        = "EC2KMSKeyPolicy"
  description = "Policy to allow EC2 to access KMS keys"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      # Allow EC2 to use KMS keys for encryption and decryption
      {
        Sid : "AllowEC2KMSAccess",
        Effect : "Allow",
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        Resource : [
          "${aws_kms_key.ec2_kms_key.arn}"
        ]
      },

      # Allow Auto Scaling to manage KMS keys for encrypted volumes
      {
        Sid : "AllowKeyAdminsToManage",
        Effect : "Allow",
        Action : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource : "*"
      },

      # Allow Auto Scaling to use the KMS key for EC2 instances with encrypted volumes
      {
        Sid : "AllowAutoScalingToUseKey",
        Effect : "Allow",
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource : "*"
      },

      # Allow Auto Scaling to create and manage grants for encrypted resources
      {
        Sid : "AllowAutoScalingGrantManagement",
        Effect : "Allow",
        Action : [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        Resource : "*",
        Condition : {
          Bool : {
            "kms:GrantIsForAWSResource" : "true"
          }
        }
      }
    ]
  })
}

# Attach the policy to the EC2 role
resource "aws_iam_role_policy_attachment" "ec2_kms_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_kms_policy.arn
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
        Resource : [
          aws_secretsmanager_secret.email_service_credentials.arn,
          aws_secretsmanager_secret.mailgun_credentials.arn
        ]
      },
      {
        Effect : "Allow",
        Action : ["kms:Decrypt"],
        Resource : aws_kms_key.secrets_kms_key.arn
      }
    ]
  })
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

# Policy for Secrets Manager and KMS access
resource "aws_iam_policy" "ec2_secrets_policy" {
  name        = "ec2_secrets_policy"
  description = "Policy for EC2 to access Secrets Manager and KMS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["secretsmanager:GetSecretValue"],
        Resource = aws_secretsmanager_secret.db_password_secret.arn
      },
      {
        Effect   = "Allow",
        Action   = ["kms:Decrypt"],
        Resource = aws_kms_key.secrets_kms_key.arn
      }
    ]
  })
}

# Attach Secrets Manager Policy to EC2 Role
resource "aws_iam_role_policy_attachment" "ec2_secrets_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_secrets_policy.arn
}

# KMS Key for RDS
resource "aws_kms_key" "rds_kms_key" {
  description             = "KMS key for RDS"
  key_usage               = "ENCRYPT_DECRYPT"
  is_enabled              = true
  enable_key_rotation     = true
  rotation_period_in_days = 90
  tags = {
    Purpose = "Encrypt RDS databases"
  }
}
resource "aws_kms_key_policy" "rds_kms_policy" {
  key_id = aws_kms_key.rds_kms_key.key_id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AllowRootAccess",
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action : "kms:*",
        Resource : "*"
        }, {
        Sid : "AllowRDSAccess",
        Effect : "Allow",
        Principal : {
          Service : "rds.amazonaws.com"
        },
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource : "*"
      }
    ]
  })
}

# IAM Policy for Secrets Manager KMS Key
resource "aws_kms_key" "secrets_kms_key" {
  description             = "KMS key for Secrets Manager"
  key_usage               = "ENCRYPT_DECRYPT"
  is_enabled              = true
  enable_key_rotation     = true
  rotation_period_in_days = 90
  tags = {
    Purpose = "Encrypt Secrets Manager secrets"
  }
}

resource "aws_kms_key_policy" "secrets_kms_policy" {
  key_id = aws_kms_key.secrets_kms_key.key_id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AllowRootAccess",
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action : "kms:*",
        Resource : "*"
      },
      {
        Sid : "AllowEC2RoleAccess",
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ec2_role_v3"
        },
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        Resource : "*"
      }
    ]
  })
}

# IAM Policy for S3 KMS Key
resource "aws_kms_key" "s3_kms_key" {
  description             = "KMS key for S3"
  key_usage               = "ENCRYPT_DECRYPT"
  is_enabled              = true
  enable_key_rotation     = true
  rotation_period_in_days = 90
  tags = {
    Purpose = "Encrypt S3 buckets"
  }
}

resource "aws_kms_key_policy" "s3_kms_policy" {
  key_id = aws_kms_key.s3_kms_key.key_id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AllowRootAccess",
        Effect : "Allow",
        Principal : {
          AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action : "kms:*",
        Resource : "*"
      },
      {
        Sid : "AllowS3Access",
        Effect : "Allow",
        Principal : {
          Service : "s3.amazonaws.com"
        },
        Action : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource : "*"
      }
    ]
  })
}
# Data block to get the AWS account ID
data "aws_caller_identity" "current" {}
