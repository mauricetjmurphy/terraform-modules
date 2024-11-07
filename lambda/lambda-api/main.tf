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



