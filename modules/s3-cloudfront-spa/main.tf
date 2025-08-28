######################################
# SPA Hosting S3 Bucket
######################################
resource "aws_s3_bucket" "spa" {
  bucket = var.bucket_name

  # ✅ Enable versioning
  versioning {
    enabled = true
  }

  # ✅ Enable KMS encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.kms_key_id
      }
    }
  }

  # ✅ Lifecycle configuration (CKV2_AWS_61)
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
}

resource "aws_s3_bucket_ownership_controls" "spa" {
  bucket = aws_s3_bucket.spa.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "spa" {
  bucket                  = aws_s3_bucket.spa.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ✅ Enforce HTTPS-only access
resource "aws_s3_bucket_policy" "spa_enforce_ssl" {
  bucket = aws_s3_bucket.spa.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "EnforceSSL",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:*",
        Resource = [
          "${aws_s3_bucket.spa.arn}",
          "${aws_s3_bucket.spa.arn}/*"
        ],
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.spa.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.spa.arn
          }
        }
      }
    ]
  })
}

######################################
# CloudFront Logging S3 Bucket
######################################
resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "${var.bucket_name}-cf-logs"

  # ✅ Versioning
  versioning {
    enabled = true
  }

  # ✅ SSE with KMS
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.kms_key_id
      }
    }
  }

  # ✅ Lifecycle for log cleanup
  lifecycle_rule {
    id      = "expire-logs"
    enabled = true
    expiration {
      days = 90
    }
  }

  tags = merge(var.tags, {
    Purpose = "CloudFrontLogs"
  })
}

resource "aws_s3_bucket_versioning" "cloudfront_logs_versioning" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudfront_logs" {
  bucket                  = aws_s3_bucket.cloudfront_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ✅ Enforce HTTPS-only access for log bucket
resource "aws_s3_bucket_policy" "cloudfront_logs_enforce_ssl" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "EnforceSSL",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:*",
        Resource = [
          "${aws_s3_bucket.cloudfront_logs.arn}",
          "${aws_s3_bucket.cloudfront_logs.arn}/*"
        ],
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
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
    target_origin_id       = "s3-${var.bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    # ✅ Attach response headers policy here
    response_headers_policy_id = aws_cloudfront_response_headers_policy.spa_security.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "IN", "EU"]
    }
  }

  viewer_certificate {
    acm_certificate_arn     = var.acm_certificate_arn
    ssl_support_method      = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # ✅ Enable access logging
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
