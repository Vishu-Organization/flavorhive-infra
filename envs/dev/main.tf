# Pull global shared resources (ACM, KMS) from global stack
data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    bucket = "flavorhive-infra-terraform-state-global"
    key    = "global/terraform.tfstate"
    region = "ap-south-1"
  }
}

module "spa_hosting" {
  source      = "../../modules/s3-cloudfront-spa"
  bucket_name = "flavorhive-dev"
  env_name    = "DEV"

  # Use global resources
  acm_certificate_arn = data.terraform_remote_state.global.outputs.acm_certificate_arn
  kms_key_id          = data.terraform_remote_state.global.outputs.kms_key_id
}

output "dev_bucket" {
  value = module.spa_hosting.bucket_name
}

output "dev_cloudfront_url" {
  value = module.spa_hosting.cloudfront_domain
}

output "dev_cloudfront_log_bucket" {
  value = module.spa_hosting.cloudfront_log_bucket
}
