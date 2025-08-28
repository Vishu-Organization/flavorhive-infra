######################################
# Providers
######################################
provider "aws" {
  region = var.primary_region
}

provider "aws" {
  alias  = "replica"
  region = var.replica_region
}

######################################
# SPA Hosting S3 Bucket
######################################
resource "aws_s3_bucket" "spa" {
  bucket = var.bucket_name

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.kms_key_id
      }
    }
  }

  lifecycle_rule {
    id      = "expire-objects"
    enabled = true
    expiration {
      days = 365
    }
    noncurrent_version_expiration {
      days = 90
    }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  logging {
    target_bucket = aws_s3_bucket.spa.id
    target_prefix = "s3-access-logs/"
  }

  tags = merge(var.tags, {
    Purpose = "SPA"
  })
}

# SPA replica bucket
resource "aws_s3_bucket" "spa_replica" {
  provider = aws.replica
  bucket   = "${var.bucket_name}-replica"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.kms_key_id
      }
    }
  }

  lifecycle_rule {
    id      = "expire-objects"
    enabled = true
    expiration {
      days = 365
    }
    noncurrent_version_expiration {
      days = 90
    }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM role for SPA replication
resource "aws_iam_role" "spa_replication" {
  name = "${var.bucket_name}-replication-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "s3.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "spa_replication_policy" {
  role = aws_iam_role.spa_replication.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectLegalHold",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectRetention"
        ],
        Resource = "${aws_s3_bucket.spa.arn}/*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        Resource = "${aws_s3_bucket.spa_replica.arn}/*"
      }
    ]
  })
}

# SPA replication configuration
resource "aws_s3_bucket_replication_configuration" "spa" {
  bucket = aws_s3_bucket.spa.id
  role   = aws_iam_role.spa_replication.arn

  rules {
    id       = "replicate-to-replica"
    status   = "Enabled"
    priority = 1
    destination {
      bucket        = aws_s3_bucket.spa_replica.arn
      storage_class = "STANDARD"
    }
    filter {
      prefix = ""
    }
  }
}

######################################
# CloudFront Logging S3 Bucket
######################################
resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "${var.bucket_name}-cf-logs"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.kms_key_id
      }
    }
  }

  lifecycle_rule {
    id      = "expire-logs"
    enabled = true
    expiration { days = 90 }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  logging {
    target_bucket = aws_s3_bucket.cloudfront_logs.bucket
    target_prefix = "s3-access-logs/"
  }

  tags = merge(var.tags, {
    Purpose = "CloudFrontLogs"
  })
}

# CloudFront logs replica bucket
resource "aws_s3_bucket" "cloudfront_logs_replica" {
  provider = aws.replica
  bucket   = "${var.bucket_name}-cf-logs-replica"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.kms_key_id
      }
    }
  }

  lifecycle_rule {
    id      = "expire-logs"
    enabled = true
    expiration { days = 90 }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM role for CloudFront logs replication
resource "aws_iam_role" "cloudfront_logs_replication" {
  name = "${var.bucket_name}-logs-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "s3.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "cloudfront_logs_replication_policy" {
  role = aws_iam_role.cloudfront_logs_replication.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectLegalHold",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectRetention"
        ],
        Resource = "${aws_s3_bucket.cloudfront_logs.arn}/*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        Resource = "${aws_s3_bucket.cloudfront_logs_replica.arn}/*"
      }
    ]
  })
}

# CloudFront logs replication configuration
resource "aws_s3_bucket_replication_configuration" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  role   = aws_iam_role.cloudfront_logs_replication.arn

  rules {
    id       = "replicate-to-replica"
    status   = "Enabled"
    priority = 1
    destination {
      bucket        = aws_s3_bucket.cloudfront_logs_replica.arn
      storage_class = "STANDARD"
    }
    filter {
      prefix = ""
    }
  }
}

######################################
# CloudFront Origin Access Control
######################################
resource "aws_cloudfront_origin_access_control" "spa" {
  name                              = "${var.bucket_name}-oac"
  description                       = "OAC for ${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

######################################
# CloudFront Response Headers Policy
######################################
resource "aws_cloudfront_response_headers_policy" "spa_security" {
  name = "${var.env_name}-security-headers"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    content_type_options {
      override = true
    }

    xss_protection {
      override           = true
      mode_block         = true
      protection_enabled = true
    }

    referrer_policy {
      override = true
      policy   = "strict-origin-when-cross-origin"
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }
  }

  comment = "Security headers for ${var.env_name} SPA distribution"
}

######################################
# CloudFront Distribution
######################################
resource "aws_cloudfront_distribution" "spa" {
  enabled             = true
  default_root_object = "index.html"
  comment             = "${var.env_name} - FlavorHive Distribution"

  origin {
    domain_name              = aws_s3_bucket.spa.bucket_regional_domain_name
    origin_id                = "s3-${var.bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.spa.id
  }

  default_cache_behavior {
    target_origin_id           = "s3-${var.bucket_name}"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    response_headers_policy_id = aws_cloudfront_response_headers_policy.spa_security.id

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "IN", "EU"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method        = "sni-only"
    minimum_protocol_version  = "TLSv1.2_2021"
  }

  logging_config {
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
    include_cookies = false
    prefix          = "cloudfront-logs/"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }
}
