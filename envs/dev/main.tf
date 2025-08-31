######################################
# IAM Role for GitHub Actions (Dev)
######################################
module "github_oidc_role" {
  source    = "../../modules/iam-roles/github-oidc-role"
  role_name = "FlavorHive-Dev-Deploy-Role"

  # GitHub repository URL in the "sub" claim
  github_sub     = "repo:Vishu-Organization/flavorhive-infra:ref:refs/heads/main"
  policy_arn     = "arn:aws:iam::aws:policy/AdministratorAccess" # or custom infra policy
  github_oidc_arn = "arn:aws:iam::${var.dev_account_id}:oidc-provider/token.actions.githubusercontent.com"
}

######################################
# Pull global shared resources (ACM, KMS)
######################################
data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    bucket = "flavorhive-infra-terraform-state-global"
    key    = "global/terraform.tfstate"
    region = "ap-south-1"
  }
}

######################################
# SPA Hosting
######################################
module "spa_hosting" {
  source      = "../../modules/s3-cloudfront-spa"
  bucket_name = "flavorhive-dev"
  env_name    = "DEV"

  acm_certificate_arn = data.terraform_remote_state.global.outputs.acm_certificate_arn
  kms_key_id          = data.terraform_remote_state.global.outputs.kms_key_id
}

######################################
# Outputs
######################################
output "dev_bucket" {
  value = module.spa_hosting.bucket_name
}

output "dev_cloudfront_url" {
  value = module.spa_hosting.cloudfront_domain
}

output "dev_cloudfront_log_bucket" {
  value = module.spa_hosting.cloudfront_log_bucket
}

output "dev_oidc_role_arn" {
  value = module.github_oidc_role.role_arn
}
