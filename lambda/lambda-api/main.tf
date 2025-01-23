##-----------------------------------------------------------------------------
## Labels module callled that will be used for naming and tags.
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
## Lambda Layers allow you to reuse shared bits of code across multiple lambda functions.
##-----------------------------------------------------------------------------
resource "aws_lambda_function" "main" {
  count            = var.enable ? 1 : 0
  description      = var.description
  function_name    = var.lambda_function_name
  memory_size      = var.memory_size
  handler          = var.handler
  runtime          = var.runtime
  filename         = "lambda-package/main.zip"
  source_code_hash = filebase64sha256("lambda-package/main.zip")
  role             = var.lambda_exec_role_arn
  timeout          = var.lambda_timeout

  # Environment Variables
  environment {
    variables = var.lambda_env_vars
  }

  depends_on = [aws_cloudwatch_log_group.lambda_log_group]
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  count = var.enable ? 1 : 0
  
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 30

  tags = module.labels.tags
}

resource "aws_lambda_permission" "lambda_permissions" {
  for_each = toset(var.statement_ids)

  statement_id  = each.value
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main[each.key].function_name
  principal     = "events.amazonaws.com"
}

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

resource "aws_iam_role_policy_attachment" "lambda_logs_attachment" {
  policy_arn = aws_iam_policy.lambda_logs_policy.arn
  role       = var.lambda_exec_role_arn
}


