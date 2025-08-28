module "spa_hosting" {
  source      = "../../modules/s3-cloudfront-spa"
  bucket_name = "flavorhive-qa"
  env_name    = "QA"

  enable_centralized_logging = false
  log_retention_days         = 30 # shorter for non-prod
  enable_s3_notifications    = true
}

output "qa_bucket" {
  value = module.spa_hosting.bucket_name
}

output "qa_cloudfront_url" {
  value = module.spa_hosting.cloudfront_domain
}
