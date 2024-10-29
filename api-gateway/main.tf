locals {
  create_routes_and_integrations = var.create && var.create_routes_and_integrations
}

################################################################################
# API Gateway v2 (HTTP API)
################################################################################

resource "aws_apigatewayv2_api" "this" {
  count = var.create ? 1 : 0

  name                         = var.name
  protocol_type                = "HTTP"
  route_key                    = null  # No default route key required for now
  fail_on_warnings             = true
  description                  = var.description
  tags                         = var.tags

  dynamic "cors_configuration" {
    for_each = var.cors_configuration != null ? [var.cors_configuration] : []

    content {
      allow_credentials = cors_configuration.value.allow_credentials
      allow_headers     = cors_configuration.value.allow_headers
      allow_methods     = cors_configuration.value.allow_methods
      allow_origins     = cors_configuration.value.allow_origins
      expose_headers    = cors_configuration.value.expose_headers
      max_age           = cors_configuration.value.max_age
    }
  }
}

################################################################################
# Routes and Integrations for Message and Booking
################################################################################

resource "aws_apigatewayv2_route" "this" {
  for_each = { for k, v in var.routes : k => v if local.create_routes_and_integrations }

  api_id       = aws_apigatewayv2_api.this[0].id
  route_key    = each.key
  authorization_type = each.value.authorization_type
  authorizer_id      = try(aws_apigatewayv2_authorizer.this[each.value.authorizer_key].id, null)

  target = "integrations/${aws_apigatewayv2_integration.this[each.key].id}"
}

resource "aws_apigatewayv2_integration" "this" {
  for_each = { for k, v in var.routes : k => v.integration if v.integration != null }

  api_id                = aws_apigatewayv2_api.this[0].id
  integration_uri       = try(each.value.uri, null)
  integration_method    = "POST"
  integration_type      = "AWS_PROXY"
  timeout_milliseconds  = try(each.value.timeout_milliseconds, null)
  payload_format_version = try(each.value.payload_format_version, null)

  dynamic "response_parameters" {
    for_each = try(each.value.response_parameters, []) != null ? [each.value.response_parameters] : []

    content {
      status_code = response_parameters.value.status_code
      mappings    = response_parameters.value.mappings
    }
  }
}

################################################################################
# Authorizers (Optional)
################################################################################

resource "aws_apigatewayv2_authorizer" "this" {
  for_each = { for k, v in var.authorizers : k => v if var.create }

  api_id = aws_apigatewayv2_api.this[0].id

  authorizer_type                   = each.value.authorizer_type
  identity_sources                  = each.value.identity_sources
  name                              = each.key

  dynamic "jwt_configuration" {
    for_each = each.value.jwt_configuration != null ? [each.value.jwt_configuration] : []

    content {
      audience = jwt_configuration.value.audience
      issuer   = jwt_configuration.value.issuer
    }
  }
}

################################################################################
# Domain Name (Optional)
################################################################################

resource "aws_apigatewayv2_domain_name" "this" {
  count = var.create_domain_name ? 1 : 0

  domain_name = var.domain_name

  domain_name_configuration {
    certificate_arn = var.domain_name_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = var.tags
}

################################################################################
# Route53 Record for Domain Name (Optional)
################################################################################

data "aws_route53_zone" "this" {
  count = var.create_domain_name && var.create_domain_records ? 1 : 0
  name  = var.hosted_zone_name
}

resource "aws_route53_record" "this" {
  for_each = var.create_domain_name && var.create_domain_records ? {
    "${var.domain_name}-A" = {
      name = var.domain_name
      type = "A"
    }
  } : {}

  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = each.value.name
  type    = each.value.type

  alias {
    name                   = aws_apigatewayv2_domain_name.this[0].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.this[0].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

################################################################################
# Stage and Deployment
################################################################################

resource "aws_apigatewayv2_stage" "this" {
  count = var.create_stage ? 1 : 0

  api_id = aws_apigatewayv2_api.this[0].id
  name   = var.stage_name

  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.this[count.index].arn
    format          = jsonencode({
    requestId          = "$context.requestId",
    ip                 = "$context.identity.sourceIp",
    caller             = "$context.identity.caller",
    user               = "$context.identity.user",
    requestTime        = "$context.requestTime",
    httpMethod         = "$context.httpMethod",
    resourcePath       = "$context.resourcePath",
    status             = "$context.status",
    protocol           = "$context.protocol",
    responseLength     = "$context.responseLength"
  })
  }

  depends_on = [aws_cloudwatch_log_group.this]
}

resource "aws_apigatewayv2_deployment" "this" {
  count = var.create_stage && var.deploy_stage ? 1 : 0

  api_id = aws_apigatewayv2_api.this[0].id

  triggers = {
    redeployment = sha1(jsonencode(aws_apigatewayv2_route.this))
  }

  depends_on = [
    aws_apigatewayv2_integration.this,
    aws_apigatewayv2_route.this
  ]
}

################################################################################
# CloudWatch Log Group for Stage
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  count = var.create_log_group ? 1 : 0

  # Define the log group name independently
  name              = "/aws/apigateway/${var.stage_name}"
  retention_in_days = var.log_group_retention_in_days

  tags = var.tags
}

