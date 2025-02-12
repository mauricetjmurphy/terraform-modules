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
    aws_api_gateway_stage.stage
  ]
}

resource "aws_api_gateway_stage" "stage" {
  stage_name    = var.stage_name
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_access_logs.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      responseLength = "$context.responseLength"
    })
  }

  xray_tracing_enabled = true

  depends_on = [
    aws_api_gateway_deployment.api_deployment
  ]
}

##----------------------------------------------------------------------------------
## Enable Execution Logging via Method Settings
##----------------------------------------------------------------------------------
resource "aws_api_gateway_method_settings" "logging" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*" # Apply logging to all API Gateway methods

  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }
}

##----------------------------------------------------------------------------------
## IAM Role for API Gateway Logging
##----------------------------------------------------------------------------------
resource "aws_api_gateway_account" "api_logging" {
  cloudwatch_role_arn = aws_iam_role.apigateway_logging_role.arn

  depends_on = [
    aws_iam_role.apigateway_logging_role,
    aws_iam_policy_attachment.apigateway_logs
  ]
}

resource "aws_iam_role" "apigateway_logging_role" {
  name = "APIGatewayCloudWatchLogsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "apigateway_logging_policy" {
  name        = "APIGatewayLoggingPolicy"
  description = "Allows API Gateway to write logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        Resource = [
          "${aws_cloudwatch_log_group.api_gateway_execution_logs.arn}",
          "${aws_cloudwatch_log_group.api_gateway_access_logs.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "apigateway_logs" {
  name       = "apigateway-logs-attachment"
  roles      = [aws_iam_role.apigateway_logging_role.name]
  policy_arn = aws_iam_policy.apigateway_logging_policy.arn
}

##----------------------------------------------------------------------------------
## CloudWatch Log Groups for Execution & Access Logs
##----------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "api_gateway_execution_logs" {
  name              = "/aws/api-gateway/${var.api_name}/execution-logs"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "api_gateway_access_logs" {
  name              = "/aws/api-gateway/${var.api_name}/access-logs"
  retention_in_days = 7
}
