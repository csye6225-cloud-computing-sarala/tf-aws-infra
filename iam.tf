# IAM Role for EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role_v2"
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

# IAM Policy for CloudWatch Agent
data "aws_iam_policy" "agent_policy" {

  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

}


# resource "aws_iam_policy" "cloudwatch_agent_policy" {
#   name        = "CloudWatchAgentServerPolicyInline"
#   path        = "/"
#   description = "Policy for CloudWatch Agent to access CloudWatch logs and metrics"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "cloudwatch:PutMetricData",
#           "ec2:DescribeTags",
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "ssm:GetParameter"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# Attach the policy to the EC2 IAM role
resource "aws_iam_role_policy_attachment" "agent_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = data.aws_iam_policy.agent_policy.arn
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
  name = "ec2_instance_profile_v2"
  role = aws_iam_role.ec2_role.name
}