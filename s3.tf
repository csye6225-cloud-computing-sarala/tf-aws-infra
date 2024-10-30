# Generate a random UUID for the bucket name
resource "random_uuid" "bucket_name" {}

# S3 Bucket Configuration
resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "my-bucket-demo-${random_uuid.bucket_name.result}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_access_block" {
  bucket = aws_s3_bucket.s3_bucket.id
}

# Enable Default Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle Policy to transition objects from STANDARD to STANDARD_IA after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "s3_lifecycle" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    id     = "TransitionToSTANDARD_IA"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}
