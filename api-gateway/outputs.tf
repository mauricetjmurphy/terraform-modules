output "api_url" {
  description = "The base URL of the API Gateway"
  value       = "${aws_api_gateway_rest_api.api.invoke_url}"
}
