###############################################################################
# Hea — Terraform Outputs
###############################################################################

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "lambda_function_name" {
  description = "Lambda inference function name"
  value       = aws_lambda_function.inference.function_name
}

output "lambda_function_arn" {
  description = "Lambda inference function ARN"
  value       = aws_lambda_function.inference.arn
}

output "model_artifacts_bucket" {
  description = "S3 bucket for ML model artifacts"
  value       = aws_s3_bucket.model_artifacts.id
}

output "feature_store_bucket" {
  description = "S3 bucket for feature store"
  value       = aws_s3_bucket.feature_store.id
}

output "users_table" {
  description = "DynamoDB Users table name"
  value       = aws_dynamodb_table.users.name
}

output "health_inputs_table" {
  description = "DynamoDB Health Inputs table name"
  value       = aws_dynamodb_table.health_inputs.name
}

output "risk_assessments_table" {
  description = "DynamoDB Risk Assessments table name"
  value       = aws_dynamodb_table.risk_assessments.name
}

output "feedback_table" {
  description = "DynamoDB Feedback table name"
  value       = aws_dynamodb_table.feedback.name
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${var.project_name}-${var.environment}"
}

output "sns_alerts_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "cicd_role_arn" {
  description = "IAM role ARN for CI/CD deployments"
  value       = aws_iam_role.cicd_deploy.arn
}
