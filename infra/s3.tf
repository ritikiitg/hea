###############################################################################
# Hea — S3 Buckets
# Model artifacts, features, access logs, and frontend hosting
###############################################################################

locals {
  bucket_prefix = "${var.project_name}-${var.environment}"
}

# ─── Model Artifacts Bucket ──────────────────────────
resource "aws_s3_bucket" "model_artifacts" {
  bucket = "${local.bucket_prefix}-model-artifacts"
}

resource "aws_s3_bucket_versioning" "model_artifacts" {
  bucket = aws_s3_bucket.model_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "model_artifacts" {
  bucket = aws_s3_bucket.model_artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "model_artifacts" {
  bucket                  = aws_s3_bucket.model_artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─── Feature Store Bucket ────────────────────────────
resource "aws_s3_bucket" "feature_store" {
  bucket = "${local.bucket_prefix}-feature-store"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "feature_store" {
  bucket = aws_s3_bucket.feature_store.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "feature_store" {
  bucket = aws_s3_bucket.feature_store.id
  rule {
    id     = "retain-features"
    status = "Enabled"
    expiration {
      days = var.data_retention_days
    }
    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "feature_store" {
  bucket                  = aws_s3_bucket.feature_store.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─── Access Logs Bucket ──────────────────────────────
resource "aws_s3_bucket" "access_logs" {
  bucket = "${local.bucket_prefix}-access-logs"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id
  rule {
    id     = "retain-logs"
    status = "Enabled"
    expiration {
      days = var.log_retention_days
    }
  }
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket                  = aws_s3_bucket.access_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
