variable "api_name" {
  description = "The name of the API Gateway"
  type        = string
}

variable "api_description" {
  description = "The description of the API Gateway"
  type        = string
  default     = "API for FastAPI Lambda functions"
}

variable "lambda_function_details" {
  description = "Map of Lambda function names to their base paths"
  type = map(string)  # Change type to match the output from Lambda module
}

