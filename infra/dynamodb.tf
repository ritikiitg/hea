###############################################################################
# Hea — DynamoDB Tables
# User data, health inputs, risk assessments, and feedback
###############################################################################

# ─── Users Table ─────────────────────────────────────
resource "aws_dynamodb_table" "users" {
  name         = "${var.project_name}-${var.environment}-users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  # GDPR: enable TTL for automatic data cleanup
  ttl {
    attribute_name = "ttl_expiry"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    DataClassification = "Sensitive"
    GDPRRelevant       = "true"
  }
}

# ─── Health Inputs Table ─────────────────────────────
resource "aws_dynamodb_table" "health_inputs" {
  name         = "${var.project_name}-${var.environment}-health-inputs"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "input_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "input_id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  local_secondary_index {
    name            = "user-date-index"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  ttl {
    attribute_name = "ttl_expiry"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    DataClassification = "Sensitive"
    GDPRRelevant       = "true"
  }
}

# ─── Risk Assessments Table ──────────────────────────
resource "aws_dynamodb_table" "risk_assessments" {
  name         = "${var.project_name}-${var.environment}-risk-assessments"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "assessment_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "assessment_id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  local_secondary_index {
    name            = "user-assessment-date-index"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  ttl {
    attribute_name = "ttl_expiry"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    DataClassification = "Sensitive"
    GDPRRelevant       = "true"
  }
}

# ─── Feedback Table ──────────────────────────────────
resource "aws_dynamodb_table" "feedback" {
  name         = "${var.project_name}-${var.environment}-feedback"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "feedback_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "feedback_id"
    type = "S"
  }

  ttl {
    attribute_name = "ttl_expiry"
    enabled        = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    DataClassification = "Sensitive"
    GDPRRelevant       = "true"
  }
}
