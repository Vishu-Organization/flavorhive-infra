variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "env_name" {
  description = "Environment name (dev, qa, stage, prod)"
  type        = string
}

variable "kms_key_id" {
  description = "KMS Key ID or ARN to use for default encryption of the SPA bucket"
  type        = string
  default     = ""  # empty means AWS-managed KMS key will be used
}

variable "tags" {
  description = "Tags to attach to all resources"
  type        = map(string)
  default     = {}
}

variable "object_expiration_days" {
  description = "Days before objects expire in SPA bucket"
  type        = number
  default     = 365
}

variable "noncurrent_version_expiration_days" {
  description = "Days before noncurrent versions expire"
  type        = number
  default     = 90
}

variable "geo_restriction_enabled" {
  description = "Enable geo restriction on CloudFront"
  type        = bool
  default     = false
}

variable "geo_locations" {
  description = "List of allowed country codes if geo restriction is enabled"
  type        = list(string)
  default     = ["US", "IN", "EU"]
}
