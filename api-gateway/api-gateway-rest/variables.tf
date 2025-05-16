variable "environment" {
  description = "Environment"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
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

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment"]
  description = "Label order, e.g. `name`,`application`."
}

variable "repository" {
  type        = string
  default     = ""
  description = "Terraform current module repo"
}

variable "endpoint_configuration" {
  type        = string
  default     = "EDGE"
  description = "Endpoint configuration. (Options: REGIONAL or EDGE)"
}

variable "rest_variables" {
  type        = map(string)
  default     = {}
  description = "Map to set on the stage managed by the stage_name argument."
}

variable "api_resources" {
  description = "Map of API resources"
  type = map(object({
    path_part  = string
    lambda_arn = string
    methods    = map(object({
      integration_uri     = string
      status_code         = string
      response_models     = map(string)
      response_parameters = optional(map(string), {})
    }))
  }))
}

variable "authorization" {
  type        = string
  default     = "NONE"
  description = "  Required The type of authorization used for the method (NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS)"
}

variable "http_method" {
  type        = string
  default     = "ANY"
  description = "HTTP method (GET, POST, PUT, DELETE, HEAD, OPTION, ANY) when calling the associated resource."
}

variable "timeout_milliseconds" {
  type        = number
  default     = null
  description = "Custom timeout between 50 and 29,000 milliseconds. The default value is 29,000 milliseconds."
}

variable "gateway_integration_type" {
  type        = string
  default     = "AWS_PROXY"
  description = "flag tp control the gatway integration type."
}

