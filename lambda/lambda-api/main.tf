##----------------------------------------------------------------------------- 
## Labels module to generate consistent naming and tagging for AWS resources.
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
## AWS Lambda function resource.
## - Supports both local file and S3-based deployments.
## - Handles environment variables and execution role.
##----------------------------------------------------------------------------- 
resource "aws_lambda_function" "main" {
  for_each         = var.enable ? { lambda = var.lambda_function_name } : {}
  description      = var.description
  function_name    = var.lambda_function_name
  memory_size      = var.memory_size
  handler          = var.handler
  runtime          = var.runtime
  role             = var.lambda_exec_role_arn
  timeout          = var.lambda_timeout

  # Conditional logic to switch between local file and S3 deployment
  filename         = var.use_s3 ? null : "lambda-package/main.zip"
  s3_bucket        = var.use_s3 ? var.s3_bucket : null
  s3_key           = var.use_s3 ? var.s3_key : null

  # Hashing for deployment consistency (only for local file deployments)
  source_code_hash = var.use_s3 ? null : filebase64sha256("lambda-package/main.zip")

  # Environment Variables for Lambda function
  environment {
    variables = var.lambda_env_vars
  }

 # Ensure IAM Role and Policies exist before Lambda function
  depends_on = [
    aws_cloudwatch_log_group.lambda_log_group,
    aws_iam_role_policy_attachment.lambda_logs_attachment,
    aws_iam_role_policy_attachment.lambda_s3_attachment,
    aws_iam_role_policy_attachment.lambda_rds_attachment
  ]
}

##----------------------------------------------------------------------------- 
## Lambda Permission Resource.
## - Defines who can invoke the Lambda function.
## - Uses CloudWatch Events as the principal.
##----------------------------------------------------------------------------- 
resource "aws_lambda_permission" "lambda_permissions" {
  for_each = toset(var.statement_ids)

  statement_id  = each.value
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main["lambda"].function_name
  principal     = "events.amazonaws.com"
}



##----------------------------------------------------------------------------- 
## IAM Policy for Lambda to write logs to CloudWatch.
## - Allows Lambda functions to create log groups, log streams, and put log events.
##----------------------------------------------------------------------------- 
resource "aws_iam_policy" "lambda_logs_policy" {
  name   = "${var.name}-lambda-logs-policy"
  description = "IAM policy for Lambda to write to CloudWatch logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = var.iam_actions
        Effect   = "Allow"
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
      }
    ]
  })
}

##----------------------------------------------------------------------------- 
## IAM Role Policy Attachment for CloudWatch Logging.
## - Attaches the logging policy to the Lambda execution role.
##----------------------------------------------------------------------------- 
resource "aws_iam_role_policy_attachment" "lambda_logs_attachment" {
  policy_arn = var.lambda_logs_policy_arn
  role       = var.lambda_exec_role_arn
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attachment" {
  policy_arn = var.lambda_s3_policy_arn
  role       = var.lambda_exec_role_arn
}

resource "aws_iam_role_policy_attachment" "lambda_rds_attachment" {
  policy_arn = var.lambda_rds_policy_arn
  role       = var.lambda_exec_role_arn
}


