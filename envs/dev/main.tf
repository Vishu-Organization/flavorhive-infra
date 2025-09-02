########################################
# Providers
########################################
provider "aws" {
  region = "ap-south-1"
}

########################################
# IAM Role for GitHub Actions (Dev)
########################################
module "github_oidc_role" {
  source    = "../../modules/iam-role"
  role_name = "FlavorHive-Dev-Deploy-Role"

  github_sub = [
    "repo:Vishu-Organization/flavorhive-infra:ref:refs/heads/main",
    "repo:Vishu-Organization/flavorhive-infra:ref:refs/pull/*/merge"
  ]

  policy_arn      = "arn:aws:iam::aws:policy/AdministratorAccess"
  github_oidc_arn = "arn:aws:iam::${var.dev_account_id}:oidc-provider/token.actions.githubusercontent.com"
  dev_account_id  = var.dev_account_id
}

########################################
# Pull global shared resources (KMS)
########################################
data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    bucket = "flavorhive-infra-terraform-state-global"
    key    = "global/terraform.tfstate"
    region = "ap-south-1"
    use_lockfile = true
  }
}

########################################
# SPA Hosting (Dev Environment)
########################################
module "spa_hosting" {
  source = "../../modules/s3-cloudfront-spa"
  bucket_name = "flavorhive-dev"
  env_name    = "DEV"

  # Pass tags and KMS
  tags       = { Environment = "DEV" }
  kms_key_id = data.terraform_remote_state.global.outputs.kms_key_id
}

########################################
# Outputs
########################################
output "dev_bucket" {
  description = "S3 bucket name for Dev SPA hosting"
  value       = module.spa_hosting.bucket_name
}

output "dev_cloudfront_log_bucket" {
  description = "Log bucket for Dev CloudFront distribution"
  value       = module.spa_hosting.cloudfront_log_bucket
}

output "dev_oidc_role_arn" {
  description = "IAM role ARN for GitHub Actions (Dev)"
  value       = module.github_oidc_role.role_arn
}
