# SPA bucket
output "bucket_name" {
  description = "Name of the SPA S3 bucket"
  value       = aws_s3_bucket.spa.bucket
}

output "bucket_arn" {
  description = "ARN of the SPA S3 bucket"
  value       = aws_s3_bucket.spa.arn
}

# CloudFront logs bucket
output "cloudfront_log_bucket" {
  description = "CloudFront logs S3 bucket"
  value       = aws_s3_bucket.cloudfront_logs.bucket
}
