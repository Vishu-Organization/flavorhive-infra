########################################
# Providers
########################################
provider "aws" {
  region = "ap-south-1" # Primary region
}

# ACM must be in us-east-1 for CloudFront
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

########################################
# Terraform Backend (remote state in S3)
########################################
terraform {
  backend "s3" {
    bucket = "flavorhive-infra-terraform-state-global"
    key    = "global/terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "flavorhive-infra-terraform-locks-global"
    encrypt        = true
  }
}

########################################
# S3 for Terraform State
########################################
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "flavorhive-infra-terraform-state-global"
  force_destroy = false

  tags = {
    Name        = "flavorhive-terraform-state"
    Environment = "global"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

########################################
# DynamoDB for Terraform Locks
########################################
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "flavorhive-infra-terraform-locks-global"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "flavorhive-terraform-locks"
    Environment = "global"
  }
}

########################################
# KMS Key (for S3 encryption, SPA buckets)
########################################
resource "aws_kms_key" "spa_key" {
  description             = "KMS key for FlavorHive SPA buckets"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Environment = "global"
    ManagedBy   = "Terraform"
  }
}

########################################
# ACM Certificate (optional placeholder)
# Only needed if you later buy a domain
########################################
# resource "aws_acm_certificate" "spa_cert" {
#   provider          = aws.us_east_1
#   domain_name       = "example.com"
#   validation_method = "DNS"
#   tags = {
#     Environment = "global"
#     ManagedBy   = "Terraform"
#   }
# }

########################################
# Outputs
########################################
output "kms_key_id" {
  description = "KMS key for S3 encryption"
  value       = aws_kms_key.spa_key.id
}

# Uncomment when you actually create ACM
# output "acm_certificate_arn" {
#   description = "ARN of the ACM certificate for SPA hosting"
#   value       = aws_acm_certificate.spa_cert.arn
# }
