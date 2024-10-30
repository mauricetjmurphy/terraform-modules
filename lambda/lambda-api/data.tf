data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_apigatewayv2_api" "main" {
  api_id = var.api_gateway_id
}

data "aws_caller_identity" "current" {}
