variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "env_name" {
  description = "Environment name (dev, qa, stage, prod)"
  type        = string
}

# -----------------------------
# CloudFront logging
# -----------------------------
variable "enable_centralized_logging" {
  description = "Whether to use a centralized CloudFront log bucket (enterprise setup)"
  type        = bool
  default     = false
}

variable "centralized_log_bucket" {
  description = "Name of the centralized log bucket (used if enable_centralized_logging is true)"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "Number of days to retain CloudFront access logs (applies only if centralized logging is disabled)"
  type        = number
  default     = 90
}

# -----------------------------
# S3 event notifications
# -----------------------------
variable "enable_s3_notifications" {
  description = "Whether to enable S3 bucket notifications (Checkov CKV2_AWS_62 compliance)"
  type        = bool
  default     = true
}


