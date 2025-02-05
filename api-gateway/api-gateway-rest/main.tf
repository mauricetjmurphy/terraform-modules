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
## Resource Policy
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
## Create API Resources Dynamically
##----------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "api_resources" {
  for_each    = var.api_resources
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = each.value.path_part
}

##----------------------------------------------------------------------------------
## Create API Methods for Each Resource
##----------------------------------------------------------------------------------
resource "aws_api_gateway_method" "rest_api_method" {
  for_each      = var.api_resources
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.api_resources[each.key].id
  http_method   = each.value.http_method
  authorization = var.authorization
}

##----------------------------------------------------------------------------------
## Create API Gateway Integrations for Each Method
##----------------------------------------------------------------------------------
resource "aws_api_gateway_integration" "rest_api_integration" {
  for_each                = var.api_resources
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.api_resources[each.key].id
  http_method             = aws_api_gateway_method.rest_api_method[each.key].http_method
  integration_http_method = var.http_method
  # connection_type         = var.connection_rest_api_type
  # connection_id           = var.connection_id
  # credentials             = var.credentials
  # request_templates       = var.request_templates
  # request_parameters      = var.request_parameters
  # cache_namespace         = var.cache_namespace
  # content_handling        = var.content_handling
  # cache_key_parameters    = var.cache_key_parameters
  type                    = var.gateway_integration_type
  timeout_milliseconds    = var.timeout_milliseconds
  uri                     = each.value.integration_uri
}

##----------------------------------------------------------------------------------
## API Gateway Proxy Method for Each Resource
##----------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "proxy_resources" {
  for_each    = var.api_resources
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_resource.api_resources[each.key].id
  path_part   = "{proxy+}"
}

##----------------------------------------------------------------------------------
## API Proxy Methods for Each Proxy Resource
##----------------------------------------------------------------------------------
resource "aws_api_gateway_method" "proxy_methods" {
  for_each      = var.api_resources
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.proxy_resources[each.key].id
  http_method   = "ANY"
  authorization = var.authorization
}

##----------------------------------------------------------------------------------
## Integrate Proxy Methods for Each Proxy Resource
##----------------------------------------------------------------------------------
resource "aws_api_gateway_integration" "proxy_integration" {
  for_each                = var.api_resources
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.proxy_resources[each.key].id
  http_method             = aws_api_gateway_method.proxy_methods[each.key].http_method
  integration_http_method = var.http_method
  type                    = var.gateway_integration_type
  timeout_milliseconds    = var.timeout_milliseconds
  uri                     = each.value.integration_uri
}


##----------------------------------------------------------------------------------
## API Gateway Method Response
##----------------------------------------------------------------------------------
resource "aws_api_gateway_method_response" "rest_api_method_response" {
  for_each          = var.api_resources
  rest_api_id       = aws_api_gateway_rest_api.rest_api.id
  resource_id       = aws_api_gateway_resource.api_resources[each.key].id
  http_method       = aws_api_gateway_method.rest_api_method[each.key].http_method
  status_code       = each.value.status_code
  response_models   = each.value.response_models
  response_parameters = length(each.value.response_parameters) > 0 ? each.value.response_parameters : {}
}

##----------------------------------------------------------------------------------
## API Gateway Integration Response
##----------------------------------------------------------------------------------
resource "aws_api_gateway_integration_response" "rest_api_integration_response" {
  for_each             = var.api_resources
  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
  resource_id          = aws_api_gateway_resource.api_resources[each.key].id
  http_method          = aws_api_gateway_method.rest_api_method[each.key].http_method
  status_code          = aws_api_gateway_method_response.rest_api_method_response[each.key].status_code
  # content_handling     = var.content_handling
  # response_parameters  = var.integration_response_parameters

  depends_on = [
    aws_api_gateway_method.rest_api_method,
    aws_api_gateway_integration.rest_api_integration,
    aws_api_gateway_method_response.rest_api_method_response
  ]
}

resource "aws_lambda_permission" "api_gateway_lambda_permission" {
  for_each      = var.api_resources
  statement_id  = "AllowAPIGatewayInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*"
}

##----------------------------------------------------------------------------------
## Deployment & Stage
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
    aws_api_gateway_method_response.rest_api_method_response,
    aws_api_gateway_integration.rest_api_integration,
    aws_api_gateway_integration_response.rest_api_integration_response,
    aws_api_gateway_method.proxy_methods,
    aws_api_gateway_integration.proxy_integration 
  ]
}

resource "aws_api_gateway_stage" "stage" {
  stage_name    = var.stage_name
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
}
