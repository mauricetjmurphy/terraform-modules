##----------------------------------------------------------------------------------
## Labels module callled that will be used for naming and tags.
##----------------------------------------------------------------------------------
module "labels" {
  source  = "git::ssh://git@github.com:mauricetjmurphy/terraform-modules.git//labels"
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}

##----------------------------------------------------------------------------------
## Api-gateway module.
##----------------------------------------------------------------------------------

resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = var.api_description
}

# Loop through each Lambda function to create resources and methods
resource "aws_api_gateway_resource" "proxy" {
  for_each = var.lambda_function_details

  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = each.key  # Use the key (e.g., "email", "booking") as the base path
}

resource "aws_api_gateway_resource" "proxy_sub" {
  for_each = var.lambda_function_details

  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.proxy[each.key].id
  path_part   = "{proxy+}"  # Allows capturing all sub-paths
}

resource "aws_api_gateway_method" "any" {
  for_each = var.lambda_function_details

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy_sub[each.key].id
  http_method = "ANY"  # Allow any HTTP method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_proxy" {
  for_each = var.lambda_function_details

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy_sub[each.key].id
  http_method = aws_api_gateway_method.any[each.key].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.function[each.key].invoke_arn  # Ensure the correct reference to the function ARN
}
