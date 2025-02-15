provider "aws" {
  region = var.region
}

##----------------------------------------------------------------------------------
## Labels module for Naming and Tags
##----------------------------------------------------------------------------------
module "labels" {
  source      = "../../labels"
  name        = var.api_name
  environment = var.environment
  label_order = var.label_order
  repository  = var.repository
}

##----------------------------------------------------------------------------------
## REST API Gateway
##----------------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "rest_api" {
  name        = module.labels.id
  description = var.api_description
  tags        = module.labels.tags

  endpoint_configuration {
    types = [var.endpoint_configuration]
  }
}

##----------------------------------------------------------------------------------
## Resource Policy (Public API)
##----------------------------------------------------------------------------------
resource "aws_api_gateway_rest_api_policy" "public_api_policy" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "${aws_api_gateway_rest_api.rest_api.execution_arn}/*"
        }
    ]
}
EOF
}

##----------------------------------------------------------------------------------
## API Gateway Deployment & Stage
##----------------------------------------------------------------------------------
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  triggers = {
    redeployment = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.rest_api_method,
    aws_api_gateway_integration.rest_api_integration,
    aws_api_gateway_integration_response.integration_response
  ]
}

resource "aws_api_gateway_stage" "stage" {
  stage_name    = var.stage_name
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id

  xray_tracing_enabled = true

  depends_on = [
    aws_api_gateway_deployment.api_deployment
  ]
}

##----------------------------------------------------------------------------------
## Define API Gateway Resources, Methods & Integrations
##----------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "api_resources" {
  for_each    = var.api_resources
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = each.value.path_part
}

resource "aws_api_gateway_method" "rest_api_method" {
  for_each      = var.api_resources
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.api_resources[each.key].id
  http_method   = each.value.http_method
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "method_response" {
  for_each    = var.api_resources
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.api_resources[each.key].id
  http_method = aws_api_gateway_method.rest_api_method[each.key].http_method
  status_code = each.value.status_code

  response_models = each.value.response_models
}

resource "aws_api_gateway_integration" "rest_api_integration" {
  for_each                = var.api_resources
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.api_resources[each.key].id
  http_method             = aws_api_gateway_method.rest_api_method[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = each.value.integration_uri
}

resource "aws_api_gateway_integration_response" "integration_response" {
  for_each    = var.api_resources
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.api_resources[each.key].id
  http_method = aws_api_gateway_method.rest_api_method[each.key].http_method
  status_code = each.value.status_code

  response_parameters = each.value.response_parameters

  depends_on = [
    aws_api_gateway_integration.rest_api_integration
  ]
}

##----------------------------------------------------------------------------------
## Lambda Permissions for API Gateway
##----------------------------------------------------------------------------------
resource "aws_lambda_permission" "api_gateway_lambda_permission" {
  for_each      = var.api_resources
  statement_id  = "AllowAPIGatewayInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*"

  depends_on = [
    aws_api_gateway_integration.rest_api_integration
  ]
}

##----------------------------------------------------------------------------------
## Proxy Resources for API Gateway
##----------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "proxy_resources" {
  for_each    = var.api_resources
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_resource.api_resources[each.key].id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_methods" {
  for_each      = var.api_resources
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.proxy_resources[each.key].id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_integration" {
  for_each                = var.api_resources
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.proxy_resources[each.key].id
  http_method             = aws_api_gateway_method.proxy_methods[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = each.value.integration_uri
}
