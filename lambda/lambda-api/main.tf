##-----------------------------------------------------------------------------
## Labels module callled that will be used for naming and tags.
##-----------------------------------------------------------------------------
module "labels" {
  source      = "git::ssh://git@github.com/mauricetjmurphy/gemtech-terraform-modules.git//labels"
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
  source_code_hash = filebase64sha256("lambda/lambda-package/main.zip")
  role             = aws_iam_role.lambda_exec.arn
  timeout          = var.lambda_timeout
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${var.lambda_function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}



