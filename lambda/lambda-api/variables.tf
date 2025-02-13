variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "name" {
  type        = string
  default     = ""
  description = "Name (e.g. `app` or `cluster`)."
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

variable "s3_bucket" {
  type        = string
  description = "The S3 bucket where the Lambda function code is stored"
}

variable "s3_key" {
  type        = string
  description = "The S3 key (path) for the Lambda function package"
}

variable "use_s3" {
  type        = bool
  default     = false
  description = "Set to true to deploy from S3, false to use local file"
}

variable "lambda_exec_role_arn" {
  type        = string
  description = "IAM execution role ARN for the Lambda function."
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
  default     = 60
}

variable "lambda_env_vars" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "statement_ids" {
  type        = list(string)
  description = "List of statement IDs for Lambda permissions."
  default     = []
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnets"
  default     = []
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security groups"
  default     = []
}




