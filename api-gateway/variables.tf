variable "create" {
  description = "Whether to create the API Gateway"
  type        = bool
  default     = true
}

variable "create_routes_and_integrations" {
  description = "Whether to create routes and integrations"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the API Gateway"
  type        = string
}

variable "description" {
  description = "Description of the API Gateway"
  type        = string
}

variable "cors_configuration" {
  description = "Configuration for CORS"
  type = object({
    allow_credentials = bool
    allow_headers     = list(string)
    allow_methods     = list(string)
    allow_origins     = list(string)
    expose_headers    = list(string)
    max_age           = number
  })
  default = null
}

variable "routes" {
  description = "Map of routes and integrations"
  type = map(object({
    authorization_type   = string
    authorizer_key       = string
    authorization_scopes = list(string)
    integration = object({
      uri                     = string
      timeout_milliseconds    = number
      payload_format_version  = string
      response_parameters     = object({
        status_code = number
        mappings    = map(string)
      })
    })
  }))
}

variable "authorizers" {
  description = "Map of authorizers"
  type = map(object({
    authorizer_type  = string
    identity_sources = list(string)
    jwt_configuration = object({
      audience = list(string)
      issuer   = string
    })
  }))
  default = {}
}

variable "domain_name" {
  description = "The custom domain name for the API Gateway"
  type        = string
  default     = ""
}

variable "domain_name_certificate_arn" {
  description = "ARN of the certificate for the domain"
  type        = string
}

variable "create_domain_name" {
  description = "Whether to create a custom domain name"
  type        = bool
  default     = false
}

variable "create_domain_records" {
  description = "Whether to create DNS records for the domain"
  type        = bool
  default     = false
}

variable "hosted_zone_name" {
  description = "Hosted Zone name for Route53"
  type        = string
  default     = ""
}

variable "create_stage" {
  description = "Whether to create a stage"
  type        = bool
  default     = true
}

variable "deploy_stage" {
  description = "Whether to deploy the stage"
  type        = bool
  default     = true
}

variable "stage_name" {
  description = "Stage name"
  type        = string
  default     = "dev"
}

variable "create_log_group" {
  description = "Whether to create a CloudWatch log group"
  type        = bool
  default     = true
}

variable "log_group_retention_in_days" {
  description = "Retention time for log group"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
}


