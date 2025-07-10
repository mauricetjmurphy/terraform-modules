variable "environment" {
  description = "Deployment environment (e.g. production, staging)"
  type        = string
}

variable "lambda_function_name" {
  type = string
}

variable "description" {
  type = string
}

variable "lambda_exec_role_arn" {
  type = string
}

variable "handler" {
  type = string
}

variable "runtime" {
  type = string
}

variable "lambda_timeout" {
  type    = number
  default = 300
}

variable "s3_bucket" {
  type = string
}

variable "s3_key" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "lambda_env_vars" {
  type = map(string)
}

variable "enable_cloudwatch_permission" {
  description = "Whether to create a CloudWatch invoke permission"
  type        = bool
  default     = false
}

variable "cloudwatch_event_rule_arn" {
  description = "ARN of the CloudWatch Event Rule that will trigger the Lambda"
  type        = string
  default     = null
}
