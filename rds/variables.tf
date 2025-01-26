variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC Id"
  type        = string
  default     = "vpc-0a957f3c148b30050"
}

variable "allocated_storage" {
  description = "The allocated storage size in GB"
  type        = number
  default     = 20
}

variable "engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0.30"
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "username" {
  description = "Master username for the database"
  type        = string
}

variable "secret_name" {
  description = "The name of the AWS Secrets Manager secret"
  type        = string
  default     = "gemtech-rds-mysql-credentials"
}

variable "publicly_accessible" {
  description = "Whether the database is publicly accessible"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip a final snapshot when deleting the database"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "The number of days to retain backups for"
  type        = number
  default     = 7
}

variable "storage_type" {
  description = "The storage type to use (standard, gp2, or io1)"
  type        = string
  default     = "gp2"
}

variable "storage_encrypted" {
  description = "Whether to enable storage encryption"
  type        = bool
  default     = true
}

variable "azs" {
  description = "List of availability zones to create subnets in"
  type        = list(string)
}

variable "base_cidr" {
  description = "Base CIDR block for creating subnets"
  type        = string
  default     = "172.31.0.0/16"
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
  default     = {}
}
