###############################################################################
# Hea — CloudWatch Monitoring & Alerts
###############################################################################

# ─── Log Groups ──────────────────────────────────────
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.inference.function_name}"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.main.name}"
  retention_in_days = var.log_retention_days
}

# ─── SNS Topic for Alerts ────────────────────────────
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"
}

# ─── Lambda Error Alarm ──────────────────────────────
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Lambda inference errors exceeded threshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.inference.function_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

# ─── Lambda Duration Alarm ───────────────────────────
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${var.project_name}-${var.environment}-lambda-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Average"
  threshold           = var.lambda_timeout * 800  # 80% of timeout in ms
  alarm_description   = "Lambda inference duration approaching timeout"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.inference.function_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# ─── API Gateway 5xx Alarm ───────────────────────────
resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-api-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "5xx"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "API Gateway 5xx errors exceeded threshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiId = aws_apigatewayv2_api.main.id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# ─── API Gateway Latency Alarm ───────────────────────
resource "aws_cloudwatch_metric_alarm" "api_latency" {
  alarm_name          = "${var.project_name}-${var.environment}-api-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "p95"
  threshold           = 5000
  alarm_description   = "API Gateway p95 latency exceeds 5 seconds"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiId = aws_apigatewayv2_api.main.id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# ─── DynamoDB Throttle Alarm ─────────────────────────
resource "aws_cloudwatch_metric_alarm" "dynamo_throttle" {
  alarm_name          = "${var.project_name}-${var.environment}-dynamo-throttle"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "DynamoDB requests being throttled"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# ─── Custom Dashboard ────────────────────────────────
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "Lambda Invocations & Errors"
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.inference.function_name],
            ["AWS/Lambda", "Errors", "FunctionName", aws_lambda_function.inference.function_name],
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title   = "API Gateway Requests"
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiId", aws_apigatewayv2_api.main.id],
            ["AWS/ApiGateway", "5xx", "ApiId", aws_apigatewayv2_api.main.id],
            ["AWS/ApiGateway", "4xx", "ApiId", aws_apigatewayv2_api.main.id],
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "Lambda Duration (ms)"
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.inference.function_name, { stat = "Average" }],
            ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.inference.function_name, { stat = "p95" }],
          ]
          period = 300
          region = var.aws_region
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title   = "DynamoDB Read/Write Capacity"
          metrics = [
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", aws_dynamodb_table.health_inputs.name],
            ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", aws_dynamodb_table.health_inputs.name],
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
        }
      }
    ]
  })
}
