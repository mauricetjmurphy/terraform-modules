output "api_id" {
  description = "The API identifier."
  value       = aws_apigatewayv2_api.this[0].id
}

output "api_arn" {
  description = "The API ARN."
  value       = aws_apigatewayv2_api.this[0].arn
}

output "api_endpoint" {
  description = "The base URL of the API Gateway."
  value       = aws_apigatewayv2_api.this[0].api_endpoint
}
