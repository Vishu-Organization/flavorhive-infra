variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "env_name" {
  description = "Environment name (dev, qa, stage, prod)"
  type        = string
}

variable "enable_centralized_logging" {
  description = "Whether to use a centralized logging bucket (enterprise standard)"
  type        = bool
  default     = false
}

variable "centralized_log_bucket" {
  description = "S3 bucket domain name for centralized logging (must be set if enable_centralized_logging = true)"
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "Number of days to retain CloudFront access logs (only applies if centralized logging is disabled)"
  type        = number
  default     = 90
}


