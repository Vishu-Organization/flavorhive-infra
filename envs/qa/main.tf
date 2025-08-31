######################################
# IAM Role for GitHub Actions (QA)
######################################
module "github_oidc_role" {
  source    = "../../modules/iam-roles/github-oidc-role"
  role_name = "FlavorHive-QA-Deploy-Role"

  github_sub     = "repo:Vishu-Organization/flavorhive-infra:ref:refs/heads/release/*"
  policy_arn     = "arn:aws:iam::aws:policy/AdministratorAccess" # or custom infra policy
  github_oidc_arn = "arn:aws:iam::${var.qa_account_id}:oidc-provider/token.actions.githubusercontent.com"
}

######################################
# SPA Hosting
######################################
module "spa_hosting" {
  source      = "../../modules/s3-cloudfront-spa"
  bucket_name = "flavorhive-qa"
  env_name    = "QA"

  acm_certificate_arn = data.terraform_remote_state.global.outputs.acm_certificate_arn
  kms_key_id          = data.terraform_remote_state.global.outputs.kms_key_id
}

######################################
# Outputs
######################################
output "qa_bucket" {
  value = module.spa_hosting.bucket_name
}

output "qa_cloudfront_url" {
  value = module.spa_hosting.cloudfront_domain
}

output "qa_cloudfront_log_bucket" {
  value = module.spa_hosting.cloudfront_log_bucket
}

output "qa_oidc_role_arn" {
  value = module.github_oidc_role.role_arn
}
