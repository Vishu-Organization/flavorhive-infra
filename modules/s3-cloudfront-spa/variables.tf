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

