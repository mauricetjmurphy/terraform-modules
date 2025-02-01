##----------------------------------------------------------------------------- 
## Labels module for consistent naming and tagging.
##----------------------------------------------------------------------------- 
module "labels" {
  source      = "../../labels"
  name        = var.name
  repository  = var.repository
  environment = var.environment
  managedby   = var.managedby
  attributes  = var.attributes
  label_order = var.label_order
}

##----------------------------------------------------------------------------- 
## IAM Role for Lambda Execution
## - This role is created once and used for all Lambda functions.
##----------------------------------------------------------------------------- 
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.name}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

##----------------------------------------------------------------------------- 
## IAM Policy for CloudWatch Logs
##----------------------------------------------------------------------------- 
resource "aws_iam_policy" "lambda_logs_policy" {
  name        = "${var.name}-lambda-logs-policy"
  description = "IAM policy for Lambda to write to CloudWatch logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      Effect   = "Allow"
      Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    }]
  })
}

##----------------------------------------------------------------------------- 
## Attach IAM Policies to the Lambda Execution Role
##----------------------------------------------------------------------------- 
resource "aws_iam_role_policy_attachment" "lambda_logs_attachment" {
  policy_arn = aws_iam_policy.lambda_logs_policy.arn
  role       = aws_iam_role.lambda_exec_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attachment" {
  policy_arn = var.lambda_s3_policy_arn
  role       = aws_iam_role.lambda_exec_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_rds_attachment" {
  policy_arn = var.lambda_rds_policy_arn
  role       = aws_iam_role.lambda_exec_role.name
}

##----------------------------------------------------------------------------- 
## AWS Lambda Function Resource
## - Supports dynamic creation of multiple Lambda functions.
##----------------------------------------------------------------------------- 
resource "aws_lambda_function" "main" {
  function_name    = var.lambda_function_name
  description      = var.description
  memory_size      = var.memory_size
  handler          = var.handler
  runtime          = var.runtime
  role             = aws_iam_role.lambda_exec_role.arn
  timeout          = var.lambda_timeout

  # Conditional logic for deployment method
  filename         = var.use_s3 ? null : "lambda-package/main.zip"
  s3_bucket        = var.use_s3 ? var.s3_bucket : null
  s3_key           = var.use_s3 ? var.s3_key : null
  source_code_hash = var.use_s3 ? null : filebase64sha256("lambda-package/main.zip")

  # Environment Variables for Lambda function
  environment {
    variables = var.lambda_env_vars
  }
}

##----------------------------------------------------------------------------- 
## Lambda Permission Resource
## - Defines who can invoke the Lambda function.
##----------------------------------------------------------------------------- 
resource "aws_lambda_permission" "lambda_permissions" {
  for_each = toset(var.statement_ids)

  statement_id  = each.value
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "events.amazonaws.com"
}
