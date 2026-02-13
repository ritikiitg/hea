###############################################################################
# Hea — Terraform Provider & Backend Configuration
# AWS infrastructure for the Early Health Risk Detector prototype
###############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30"
    }
  }

  # Remote state in S3 (create this bucket manually first, or use local)
  backend "s3" {
    bucket         = "hea-terraform-state"
    key            = "prototype/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "hea-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Hea"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
