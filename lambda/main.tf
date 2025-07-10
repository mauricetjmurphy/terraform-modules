resource "aws_lambda_function" "this" {
  function_name = var.lambda_function_name
  description   = var.description
  role          = var.lambda_exec_role_arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.lambda_timeout
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = var.lambda_env_vars
  }

  tags = {
    environment = var.environment
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  count         = var.enable_cloudwatch_permission && var.cloudwatch_event_rule_arn != null ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.cloudwatch_event_rule_arn
}
