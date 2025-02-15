################################################################################
# General Settings
################################################################################

variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Secret Configuration
################################################################################

variable "description" {
  description = "A description of the secret"
  type        = string
  default     = null
}

variable "force_overwrite_replica_secret" {
  description = "Overwrite an existing secret in the destination region when replicating"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "ARN or ID of the AWS KMS key used to encrypt the secret. Defaults to AWS-managed KMS key for Secrets Manager"
  type        = string
  default     = null
}

variable "name" {
  description = "Name of the secret (must be unique within the AWS account)"
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "Creates a unique name beginning with the specified prefix (useful for dynamic secrets)"
  type        = string
  default     = null
}

variable "recovery_window_in_days" {
  description = "Number of days before a deleted secret can be recovered (0 forces immediate deletion, max 30 days)"
  type        = number
  default     = 30
}

variable "replica" {
  description = "Configuration for secret replication across multiple AWS regions"
  type        = map(object({
    kms_key_id = optional(string)
    region     = string
  }))
  default     = {}
}

################################################################################
# IAM Policy for Secrets Manager
################################################################################

variable "create_policy" {
  description = "Determines whether a resource policy will be created for the secret"
  type        = bool
  default     = false
}

variable "source_policy_documents" {
  description = "List of IAM policy documents to merge for the secret policy (unique statement IDs required)"
  type        = list(string)
  default     = []
}

variable "override_policy_documents" {
  description = "List of IAM policy documents that override existing statements with the same `sid`"
  type        = list(string)
  default     = []
}

variable "policy_statements" {
  description = "Custom IAM policy statements for fine-grained access control"
  type        = map(object({
    sid           = optional(string)
    actions       = optional(list(string))
    not_actions   = optional(list(string))
    effect        = string
    resources     = optional(list(string))
    not_resources = optional(list(string))
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    not_principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    conditions = optional(list(object({
      test     = string
      values   = list(string)
      variable = string
    })))
  }))
  default = {}
}

variable "block_public_policy" {
  description = "Block public access to the secret by validating the IAM policy with Zelkova"
  type        = bool
  default     = true
}

################################################################################
# Secret Values & Versioning
################################################################################

variable "ignore_secret_changes" {
  description = "If `true`, Terraform will ignore changes made outside of Terraform (useful for externally managed secrets)"
  type        = bool
  default     = false
}

variable "secret_values" {
  description = "Map of key-value pairs to store in AWS Secrets Manager"
  type        = map(string)
  default     = {}
}

variable "secret_binary" {
  description = "Binary data to store in the secret (Base64-encoded, mutually exclusive with `secret_values`)"
  type        = string
  default     = null
}

variable "version_stages" {
  description = "List of version staging labels to attach to this version of the secret"
  type        = list(string)
  default     = []
}

################################################################################
# Secret Rotation
################################################################################

variable "enable_rotation" {
  description = "Enable automatic secret rotation"
  type        = bool
  default     = false
}

variable "rotation_lambda_arn" {
  description = "ARN of the Lambda function that will rotate the secret"
  type        = string
  default     = null
}

variable "rotation_rules" {
  description = "Configuration for secret rotation schedule"
  type        = object({
    automatically_after_days = optional(number, 30)
    duration                 = optional(string)
    schedule_expression      = optional(string)
  })
  default = null
}
