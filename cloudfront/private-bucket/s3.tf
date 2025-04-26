# Get AWS account ID
data "aws_caller_identity" "current" {}

# S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  tags   = merge(var.s3_tags, { Name = var.bucket_name })
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Website Hosting (Optional, still included)
resource "aws_s3_bucket_website_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

# S3 CORS Configuration
resource "aws_s3_bucket_cors_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "main-public-block" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Ownership Controls
resource "aws_s3_bucket_ownership_controls" "main-ownership-control" {
  bucket = aws_s3_bucket.main.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# S3 ACL
resource "aws_s3_bucket_acl" "main_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.main-ownership-control]
  bucket     = aws_s3_bucket.main.id
  acl        = "private"
}

# S3 Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main-sse" {
  bucket = aws_s3_bucket.main.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Policy for CloudFront OAC Access
data "aws_iam_policy_document" "cfn_s3policy_doc" {
  statement {
    sid     = "AllowCloudFrontAccessViaOAC"
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.main.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [
        "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.s3_distribution.id}"
      ]
    }
  }
}

# Merge extra policies if provided
data "aws_iam_policy_document" "s3_resource_policy_doc" {
  source_policy_documents = concat(
    [data.aws_iam_policy_document.cfn_s3policy_doc.json],
    var.extra_policy_documents,
  )
}

# Apply the bucket policy
resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.s3_resource_policy_doc.json
}
