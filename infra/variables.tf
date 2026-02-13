###############################################################################
# Hea — Terraform Variables
###############################################################################

variable "aws_region" {
  description = "AWS region for all resources (UK data residency)"
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prototype"
  validation {
    condition     = contains(["prototype", "staging", "production"], var.environment)
    error_message = "Environment must be prototype, staging, or production."
  }
}

variable "project_name" {
  description = "Project identifier used in resource naming"
  type        = string
  default     = "hea"
}

variable "lambda_memory_size" {
  description = "Memory (MB) for Lambda inference function"
  type        = number
  default     = 1024
}

variable "lambda_timeout" {
  description = "Timeout (seconds) for Lambda inference function"
  type        = number
  default     = 30
}

variable "data_retention_days" {
  description = "Data retention in days (GDPR compliance)"
  type        = number
  default     = 365
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 90
}

variable "api_throttle_rate_limit" {
  description = "API Gateway rate limit (requests/sec)"
  type        = number
  default     = 50
}

variable "api_throttle_burst_limit" {
  description = "API Gateway burst limit"
  type        = number
  default     = 100
}

variable "enable_waf" {
  description = "Enable WAF for API Gateway"
  type        = bool
  default     = false
}
