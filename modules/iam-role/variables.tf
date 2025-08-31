variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "github_oidc_arn" {
  description = "ARN of the GitHub OIDC provider"
  type        = string
}

variable "github_sub" {
  description = "OIDC subject pattern allowed to assume the role. e.g. repo:ORG/REPO:*"
  type        = string
}

variable "policy_arn" {
  description = "Policy ARN to attach to role (use a least-privilege policy in prod)"
  type        = string
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
}
