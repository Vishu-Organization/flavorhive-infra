variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "env_name" {
  description = "Environment name (dev, qa, stage, prod)"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for CloudFront distribution (must be in us-east-1)"
  type        = string
}

variable "kms_key_id" {
  description = "KMS Key ID or ARN to use for default encryption of the SPA bucket"
  type        = string
  default     = ""  # empty means AWS-managed KMS key will be used
}

variable "replica_region" {
  description = "Region to replicate S3 CloudFront logs for cross-region replication"
  type        = string
  default     = "us-west-2" # You can change this as per your requirements
}

variable "tags" {
  description = "Tags to attach to all S3 buckets and resources"
  type        = map(string)
  default     = {}
}
