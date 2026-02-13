###############################################################################
# Hea — IAM Roles & Policies
# Least-privilege access for Lambda and CI/CD
###############################################################################

# ─── Lambda Execution Role ───────────────────────────
resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-${var.environment}-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# X-Ray Tracing
resource "aws_iam_role_policy_attachment" "lambda_xray" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# Custom policy: DynamoDB + S3 access
resource "aws_iam_role_policy" "lambda_data_access" {
  name = "${var.project_name}-${var.environment}-lambda-data"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:BatchWriteItem",
        ]
        Resource = [
          aws_dynamodb_table.users.arn,
          "${aws_dynamodb_table.users.arn}/index/*",
          aws_dynamodb_table.health_inputs.arn,
          "${aws_dynamodb_table.health_inputs.arn}/index/*",
          aws_dynamodb_table.risk_assessments.arn,
          "${aws_dynamodb_table.risk_assessments.arn}/index/*",
          aws_dynamodb_table.feedback.arn,
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
        ]
        Resource = [
          aws_s3_bucket.model_artifacts.arn,
          "${aws_s3_bucket.model_artifacts.arn}/*",
          aws_s3_bucket.feature_store.arn,
          "${aws_s3_bucket.feature_store.arn}/*",
        ]
      }
    ]
  })
}

# ─── CI/CD Deployment Role ───────────────────────────
resource "aws_iam_role" "cicd_deploy" {
  name = "${var.project_name}-${var.environment}-cicd-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      # For GitHub Actions, add:
      # Principal = { Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com" }
    }]
  })
}

resource "aws_iam_role_policy" "cicd_deploy" {
  name = "${var.project_name}-${var.environment}-cicd-deploy"
  role = aws_iam_role.cicd_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
        ]
        Resource = aws_lambda_function.inference.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
        ]
        Resource = [
          "${aws_s3_bucket.model_artifacts.arn}/*",
        ]
      }
    ]
  })
}
