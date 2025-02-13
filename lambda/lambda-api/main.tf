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
## AWS Lambda Function Resource
## - Uses IAM role passed from root module
##----------------------------------------------------------------------------- 
resource "aws_lambda_function" "main" {
  function_name    = var.lambda_function_name
  description      = var.description
  memory_size      = var.memory_size
  handler          = var.handler
  runtime          = var.runtime
  role             = var.lambda_exec_role_arn  # IAM role provided by root module
  timeout          = var.lambda_timeout

  # Conditional logic for deployment method
  filename         = var.use_s3 ? null : "lambda-package/main.zip"
  s3_bucket        = var.use_s3 ? var.s3_bucket : null
  s3_key           = var.use_s3 ? var.s3_key : null
  source_code_hash = var.use_s3 ? null : filebase64sha256("lambda-package/main.zip")

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

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

# Create Log Group
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 30  # Keep logs for 30 days
}

# IAM Policy to Allow Lambda to Write Logs
resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.lambda_function_name}-logging"
  description = "IAM policy for logging from Lambda functions"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.region}:144817152095:log-group:/aws/lambda/${var.lambda_function_name}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logging_attachment" {
  policy_arn = aws_iam_policy.lambda_logging.arn
  role       = element(split("/", var.lambda_exec_role_arn), 1)
}
