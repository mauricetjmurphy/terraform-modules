##----------------------------------------------------------------------------- 
## Below resource will deploy IAM role in AWS environment.   
##-----------------------------------------------------------------------------
resource "aws_iam_role" "lambda_exec" {
  name               = "${var.lambda_function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.lambda_function_name}-logging"
  description = "Policy to allow Lambda functions to write logs to CloudWatch"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "s3_access" {
  name        = "${var.lambda_function_name}-s3-access"
  description = "Policy to allow Lambda functions to access S3"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",   # Allows listing of buckets
          "s3:GetObject",    # Allows getting objects from S3
          "s3:PutObject",    # Allows putting objects to S3
          "s3:DeleteObject"  # Allows deleting objects from S3
        ]
        Resource = [
          "*",  # You can specify more restrictive resource ARNs if necessary
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "dynamodb_access" {
  name        = "${var.lambda_function_name}-dynamodb-access"
  description = "Policy to allow Lambda functions to access DynamoDB"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",    # Allows adding items to a DynamoDB table
          "dynamodb:GetItem",     # Allows retrieving items from a DynamoDB table
          "dynamodb:UpdateItem",  # Allows updating items in a DynamoDB table
          "dynamodb:DeleteItem",  # Allows deleting items from a DynamoDB table
          "dynamodb:Scan",        # Allows scanning the entire table
          "dynamodb:Query"        # Allows querying the table
        ]
        Resource = [
          "*",  # You can specify ARNs for specific tables if necessary
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_lambda_logging" {
  policy_arn = aws_iam_policy.lambda_logging.arn
  role       = aws_iam_role.lambda_exec.name
}

resource "aws_iam_role_policy_attachment" "attach_s3_access" {
  policy_arn = aws_iam_policy.s3_access.arn
  role       = aws_iam_role.lambda_exec.name
}

resource "aws_iam_role_policy_attachment" "attach_dynamodb_access" {
  policy_arn = aws_iam_policy.dynamodb_access.arn
  role       = aws_iam_role.lambda_exec.name
}
