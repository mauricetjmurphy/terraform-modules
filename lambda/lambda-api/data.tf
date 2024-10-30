data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_api_gateway_rest_api" "my_api" {
  name = var.api_gateway_name
}

data "aws_caller_identity" "current" {}
