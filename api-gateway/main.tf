resource "aws_api_gateway_rest_api" "this" {
  name = var.api_name
}

resource "aws_api_gateway_resource" "resource" {
  for_each = var.api_resources

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value.path_part
}

resource "aws_api_gateway_method" "method" {
  for_each = {
    for pair in flatten([
      for resource_key, resource in var.api_resources :
      [
        for method_name, method_config in resource.methods :
        {
          key = "${resource_key}-${method_name}"
          value = {
            resource_key = resource_key
            method_name  = method_name
            config       = method_config
          }
        }
      ]
    ]) : pair.key => pair.value
  }

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.resource[each.value.resource_key].id
  http_method   = upper(each.value.method_name)
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  for_each = {
    for pair in flatten([
      for resource_key, resource in var.api_resources :
      [
        for method_name, method_config in resource.methods :
        {
          key = "${resource_key}-${method_name}"
          value = {
            resource_key = resource_key
            method_name  = method_name
            config       = method_config
          }
        }
      ]
    ]) : pair.key => pair.value
  }

  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.resource[each.value.resource_key].id
  http_method             = upper(each.value.method_name)
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = each.value.config.integration_uri
}

resource "aws_api_gateway_resource" "payment_proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.resource["payment"].id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "payment_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.payment_proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "payment_proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.payment_proxy.id
  http_method             = aws_api_gateway_method.payment_proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.payment_service_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_method.method,
    aws_api_gateway_integration.integration,
    aws_api_gateway_method.payment_proxy_method,
    aws_api_gateway_integration.payment_proxy_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode(var.api_resources))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name    = var.environment
}

