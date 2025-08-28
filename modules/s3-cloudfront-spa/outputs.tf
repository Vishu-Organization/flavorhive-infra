# SPA S3 bucket
output "bucket_name" {
  description = "Name of the SPA S3 bucket"
  value       = aws_s3_bucket.spa.bucket
}

output "bucket_arn" {
  description = "ARN of the SPA S3 bucket"
  value       = aws_s3_bucket.spa.arn
}

output "spa_bucket_notifications_enabled" {
  description = "Indicates that S3 bucket notifications are enabled for the SPA bucket"
  value       = true
}

output "spa_sns_topic_arn" {
  description = "ARN of the SNS topic receiving S3 bucket notifications"
  value       = aws_sns_topic.spa_events.arn
}

# CloudFront distribution
output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.spa.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.spa.id
}

output "cloudfront_viewer_certificate_acm_arn" {
  description = "ACM certificate ARN used for CloudFront TLS v1.2"
  value       = var.acm_certificate_arn
}

# CloudFront logs bucket
output "cloudfront_log_bucket" {
  description = "S3 bucket storing CloudFront logs"
  value       = aws_s3_bucket.cloudfront_logs.bucket
}

# CloudFront logs replication bucket (cross-region)
output "cloudfront_log_replica_bucket" {
  description = "Cross-region replication destination bucket for CloudFront logs"
  value       = aws_s3_bucket.cloudfront_logs_replica.bucket
}
