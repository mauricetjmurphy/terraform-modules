data "aws_iam_policy_document" "cfn_s3policy_doc" {
  statement {
    sid     = "PolicyForCloudFrontPrivateContent"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.cloudfront.id}"
      ]
    }
    resources = ["${aws_s3_bucket.main.arn}/*"]
  }
}

data "aws_iam_policy_document" "s3_resource_policy_doc" {
  source_policy_documents = concat(
    [data.aws_iam_policy_document.cfn_s3policy_doc.json],
    var.extra_policy_documents,
  )
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.s3_resource_policy_doc.json
}

resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  tags   = merge(var.s3_tags, { Name = var.bucket_name })
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_website_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

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

resource "aws_s3_bucket_public_access_block" "main-public-block" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "main-ownership-control" {
  bucket = aws_s3_bucket.main.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "main_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.main-ownership-control]
  bucket     = aws_s3_bucket.main.id
  acl        = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main-sse" {
  bucket = aws_s3_bucket.main.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
