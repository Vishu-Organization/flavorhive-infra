provider "aws" {
  region = "ap-south-1"
}

########################################
# S3 bucket for Terraform state (Dev)
########################################
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "flavorhive-infra-terraform-state-dev"
  force_destroy = false

  tags = {
    Name        = "flavorhive-terraform-state-dev"
    Environment = "dev"
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
# DynamoDB for Terraform locks
########################################
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "flavorhive-infra-terraform-locks-dev"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "flavorhive-infra-terraform-locks-dev"
    Environment = "dev"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table" {
  value = aws_dynamodb_table.terraform_locks.name
}
