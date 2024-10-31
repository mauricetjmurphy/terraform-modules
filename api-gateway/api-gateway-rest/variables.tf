variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "api_name" {
  description = "The name of the API Gateway"
  type        = string
}

variable "api_description" {
  description = "Description for the API Gateway"
  type        = string
  default     = "API Gateway with Lambda Proxy Integration"
}

variable "stage_name" {
  description = "The name of the stage for deployment"
  type        = string
  default     = "dev"
}
