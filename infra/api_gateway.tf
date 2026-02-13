###############################################################################
# Hea — API Gateway (HTTP API v2)
# RESTful API routing to Lambda inference function
###############################################################################

# ─── HTTP API ────────────────────────────────────────
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-${var.environment}-api"
  protocol_type = "HTTP"
  description   = "Hea Early Health Risk Detector API"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization", "X-Request-ID"]
    max_age       = 3600
  }
}

# ─── Default Stage ───────────────────────────────────
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      path           = "$context.path"
      status         = "$context.status"
      responseLength = "$context.responseLength"
      integrationErr = "$context.integrationErrorMessage"
    })
  }

  default_route_settings {
    throttling_rate_limit  = var.api_throttle_rate_limit
    throttling_burst_limit = var.api_throttle_burst_limit
  }
}

# ─── Lambda Integration ─────────────────────────────
resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.inference.invoke_arn
  payload_format_version = "2.0"
}

# ─── Routes ──────────────────────────────────────────
resource "aws_apigatewayv2_route" "health_check" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "create_user" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /api/v1/users"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "submit_input" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /api/v1/inputs"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "get_inputs" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /api/v1/inputs"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "run_assessment" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /api/v1/assess"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "get_assessments" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /api/v1/assess/history"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "submit_feedback" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /api/v1/feedback"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "privacy_settings" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /api/v1/privacy/{userId}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "update_privacy" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "PUT /api/v1/privacy/{userId}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "delete_user_data" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "DELETE /api/v1/privacy/{userId}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}
