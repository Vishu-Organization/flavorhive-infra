module "spa_hosting" {
  source      = "../../modules/s3-cloudfront-spa"
  bucket_name = "flavorhive-qa"
  env_name    = "QA"
}

# SPA bucket outputs
output "qa_bucket" {
  value = module.spa_hosting.bucket_name
}

output "qa_bucket_arn" {
  value = module.spa_hosting.bucket_arn
}

# CloudFront outputs
output "qa_cloudfront_url" {
  value = module.spa_hosting.cloudfront_domain
}

output "qa_cloudfront_distribution_id" {
  value = module.spa_hosting.cloudfront_distribution_id
}

output "qa_cloudfront_viewer_certificate_acm_arn" {
  value = module.spa_hosting.cloudfront_viewer_certificate_acm_arn
}

# CloudFront logs outputs
output "qa_cloudfront_log_bucket" {
  value = module.spa_hosting.cloudfront_log_bucket
}

output "qa_cloudfront_log_replica_bucket" {
  value = module.spa_hosting.cloudfront_log_replica_bucket
}
