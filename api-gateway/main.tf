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
    for resource_key, resource in var.api_resources :
    "${resource_key}" => resource.methods
  }

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.resource[each.key].id
  http_method   = upper(keys(each.value)[0])
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  for_each = {
    for resource_key, resource in var.api_resources :
    "${resource_key}" => resource.methods
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.resource[each.key].id
  http_method = upper(keys(each.value)[0])
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = each.value[upper(keys(each.value)[0])].integration_uri
}

resource "aws_api_gateway_deployment" "deployment" {
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

