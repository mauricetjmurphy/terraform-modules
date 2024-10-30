variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/mauricetjmurphy/terraform-modules/tree/master/lambda"
  description = "Terraform current module repo"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment"]
  description = "Label order, e.g. `name`,`application`."
}

variable "attributes" {
  type        = list(any)
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "managedby" {
  type        = string
  default     = "mauricetjmurphy@gmail.com"
  description = "ManagedBy, eg 'Gemtech Solutions'."
}

variable "description" {
  type        = string
  default     = ""
  description = "Description of what your Lambda Function does."
}

variable "memory_size" {
  type        = number
  default     = 128
  description = "Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128."
}

variable "handler" {
  type        = string
  description = "The function entrypoint in your code."
}

variable "runtime" {
  type        = string
  default     = "python3.9"
  description = "Runtimes."
}

variable "enable" {
  type        = bool
  default     = true
  description = "Whether to create lambda function."
}

variable "lambda_function_name" {
  description = "The base name for the Lambda functions"
  type        = string
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda functions in seconds"
  type        = number
  default     = 10
}

variable "api_gateway_name" {
  description = "The API Gateway Name."
}

