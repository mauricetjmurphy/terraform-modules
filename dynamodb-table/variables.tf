variable "create_table" {
  description = "Controls if the DynamoDB table is created"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "attributes" {
  description = "List of attribute definitions (name, type). Required for hash_key and range_key."
  type        = list(map(string))
}

variable "hash_key" {
  description = "The attribute to use as the partition key (hash key)"
  type        = string
}

variable "range_key" {
  description = "The attribute to use as the sort key (optional)"
  type        = string
  default     = null
}

variable "billing_mode" {
  description = "Billing mode: PROVISIONED or PAY_PER_REQUEST"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  description = "Read capacity (only if billing_mode is PROVISIONED)"
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "Write capacity (only if billing_mode is PROVISIONED)"
  type        = number
  default     = null
}

variable "global_secondary_indexes" {
  description = "List of global secondary indexes (GSIs) for the table"
  type        = list(object({
    name            = string
    hash_key        = string
    range_key       = optional(string)
    projection_type = string
  }))
  default     = []
}

variable "local_secondary_indexes" {
  description = "List of local secondary indexes (LSIs) for the table"
  type        = list(object({
    name            = string
    range_key       = string
    projection_type = string
  }))
  default     = []
}

variable "replica_regions" {
  description = "Regions for global DynamoDB table replication"
  type        = list(object({
    region_name            = string
    kms_key_arn            = optional(string)
    propagate_tags         = optional(bool)
    point_in_time_recovery = optional(bool)
  }))
  default     = []
}

variable "stream_enabled" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Type of DynamoDB stream view"
  type        = string
  default     = null
}

variable "point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery for backups"
  type        = bool
  default     = false
}

variable "ttl_enabled" {
  description = "Enable TTL (Time-to-Live) for automatic record deletion"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Attribute used for TTL expiration timestamps"
  type        = string
  default     = null
}

variable "server_side_encryption_enabled" {
  description = "Enable encryption at rest"
  type        = bool
  default     = false
}

variable "server_side_encryption_kms_key_arn" {
  description = "KMS key ARN for encryption (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to DynamoDB resources"
  type        = map(string)
  default     = {}
}

variable "timeouts" {
  description = "Timeout settings for resource creation, update, and deletion"
  type        = map(string)
  default = {
    create = "10m"
    update = "60m"
    delete = "10m"
  }
}

variable "deletion_protection_enabled" {
  description = "Enable deletion protection for the table"
  type        = bool
  default     = false
}

variable "table_class" {
  description = "The storage class of the table. Valid values are STANDARD and STANDARD_INFREQUENT_ACCESS"
  type        = string
  default     = "STANDARD"
}
