variable "role_name" {
  description = "Name of the IAM role to create"
  type        = string
}

variable "policy_arn" {
  description = "ARN of the policy to attach to this role"
  type        = string
}

variable "github_oidc_arn" {
  description = "ARN of the GitHub OIDC provider"
  type        = string
}

variable "github_sub" {
  description = "GitHub repo refs allowed to assume this role"
  type        = list(string)
}

variable "dev_account_id" {
  description = "AWS account ID for the Dev environment"
  type        = string
}
