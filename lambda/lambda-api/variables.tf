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
