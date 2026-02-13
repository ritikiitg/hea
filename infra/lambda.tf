###############################################################################
# Hea — Lambda Functions
# Inference Lambda + packaging configuration
###############################################################################

data "aws_caller_identity" "current" {}

# ─── Lambda Inference Function ───────────────────────
resource "aws_lambda_function" "inference" {
  function_name = "${var.project_name}-${var.environment}-inference"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "app.main.handler"
  runtime       = "python3.11"
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size

  # Placeholder — in CI/CD this would point to the built zip
  filename         = "lambda_placeholder.zip"
  source_code_hash = "" # Will be computed from the zip

  environment {
    variables = {
      ENVIRONMENT        = var.environment
      MODEL_BUCKET       = aws_s3_bucket.model_artifacts.id
      FEATURE_BUCKET     = aws_s3_bucket.feature_store.id
      USERS_TABLE        = aws_dynamodb_table.users.name
      INPUTS_TABLE       = aws_dynamodb_table.health_inputs.name
      ASSESSMENTS_TABLE  = aws_dynamodb_table.risk_assessments.name
      FEEDBACK_TABLE     = aws_dynamodb_table.feedback.name
      DATA_RETENTION_DAYS = tostring(var.data_retention_days)
      LOG_LEVEL          = "INFO"
    }
  }

  # Enable X-Ray tracing
  tracing_config {
    mode = "Active"
  }

  tags = {
    Component = "Inference"
  }

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

# ─── Lambda Permission for API Gateway ───────────────
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.inference.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

# ─── Placeholder zip (Terraform needs this to plan) ──
resource "local_file" "lambda_placeholder" {
  content  = "placeholder"
  filename = "${path.module}/lambda_placeholder.zip"
}
