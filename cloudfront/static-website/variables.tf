variable "environment" {
  type        = string
  description = "Must Be Lower Case!"
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name for creating new bucket"
}

variable "domain_name" {
  type        = string
  description = "cloud front alternate domain name"
}

variable "ssl_certification_arn" {
  type        = string
  description = "ssl certificate arn that needs to be attached to cloudfront"

}

variable "aws_route53_zone_id" {
  type        = string
  description = "Route 53 zone id to associate cdn with hosted zone"
}

variable "default_root_object" {
  default     = "index.html"
  description = "CloudFront default root object"
}

variable "tags" {
  type        = map(string)
  description = "tagging for resources"
}

variable "s3_tags" {
  type        = map(string)
  default = {}
  description = "s3 tagging for resources"
}

variable "extra_policy_documents" {
  type        = list(string)
  default     = []
  description = "Additional resource policy documents"
}