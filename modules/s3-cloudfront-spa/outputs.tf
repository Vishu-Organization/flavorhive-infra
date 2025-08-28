output "bucket_name" {
  value = aws_s3_bucket.spa.bucket
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.spa.domain_name
}

output "cf_log_bucket_name" {
  description = "Name of the CloudFront access log bucket (either centralized or created per env)"
  value       = var.enable_centralized_logging ? var.centralized_log_bucket : aws_s3_bucket.cloudfront_logs[0].bucket_domain_name
}

output "cf_log_retention_days" {
  description = "Number of days logs are retained (only relevant if centralized logging disabled)"
  value       = var.enable_centralized_logging ? null : var.log_retention_days
}

output "spa_bucket_notifications_enabled" {
  description = "Indicates that S3 bucket notifications are enabled for the SPA bucket"
  value       = true
}

output "spa_sns_topic_arn" {
  description = "ARN of the SNS topic receiving S3 bucket notifications"
  value       = aws_sns_topic.spa_events.arn
}

