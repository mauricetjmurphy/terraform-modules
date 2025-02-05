output "api_url" {
  description = "The base URL of the API Gateway"
  value       = "${aws_api_gateway_rest_api.rest_api.execution_arn}/${var.stage_name}"
}

output "api_id" {
  description = "The ID of the API Gateway"
  value       = aws_api_gateway_rest_api.rest_api.id
}

output "id" {
  value = aws_api_gateway_rest_api.rest_api.id
}

output "root_resource_id" {
  value = aws_api_gateway_rest_api.rest_api.root_resource_id
}

output "execution_arn" {
  value = aws_api_gateway_rest_api.rest_api.execution_arn
}
