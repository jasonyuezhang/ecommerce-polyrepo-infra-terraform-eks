# LocalStack-only infrastructure configuration
# This file creates AWS resources that are supported by LocalStack community edition

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider configuration for LocalStack
provider "aws" {
  region = var.aws_region

  # LocalStack configuration
  access_key = "test"
  secret_key = "test"

  # Skip credential validation for LocalStack
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # LocalStack endpoints
  endpoints {
    s3             = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    logs           = "http://localhost:4566"
    iam            = "http://localhost:4566"
    sts            = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    apigateway     = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
  }

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

# Variables
variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "ecommerce"
}

variable "environment" {
  description = "Environment name (local, dev, staging, prod)"
  type        = string
  default     = "local"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Local values for consistent naming
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# S3 Bucket for application assets
# Note: Commented out due to LocalStack S3 compatibility issues with Terraform
# The bucket can be created manually with AWS CLI if needed:
# aws --endpoint-url=http://localhost:4566 s3 mb s3://ecommerce-local-assets
# resource "aws_s3_bucket" "app_assets" {
#   bucket        = "${local.name_prefix}-assets"
#   force_destroy = true
#   tags          = local.tags
# }

# DynamoDB table for session storage
resource "aws_dynamodb_table" "sessions" {
  name         = "${local.name_prefix}-sessions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "sessionId"

  attribute {
    name = "sessionId"
    type = "S"
  }

  ttl {
    attribute_name = "expiresAt"
    enabled        = true
  }

  tags = local.tags
}

# SQS queue for order processing
resource "aws_sqs_queue" "order_processing" {
  name                      = "${local.name_prefix}-order-processing"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 10

  tags = local.tags
}

# SNS topic for order notifications
resource "aws_sns_topic" "order_notifications" {
  name = "${local.name_prefix}-order-notifications"
  tags = local.tags
}

# SNS subscription to SQS
resource "aws_sns_topic_subscription" "order_notifications_to_sqs" {
  topic_arn = aws_sns_topic.order_notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.order_processing.arn
}

# Secrets Manager for database credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${local.name_prefix}-db-credentials"
  description = "Database credentials for ${var.environment} environment"
  tags        = local.tags
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "postgres"
    password = "postgres"
    database = "ecommerce"
    host     = "postgres"
    port     = 5432
  })
}

# Outputs
# S3 outputs commented out due to LocalStack compatibility issues
# output "s3_bucket_name" {
#   description = "S3 bucket name for application assets"
#   value       = aws_s3_bucket.app_assets.id
# }

# output "s3_bucket_arn" {
#   description = "S3 bucket ARN"
#   value       = aws_s3_bucket.app_assets.arn
# }

output "dynamodb_table_name" {
  description = "DynamoDB table name for sessions"
  value       = aws_dynamodb_table.sessions.name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.sessions.arn
}

output "sqs_queue_url" {
  description = "SQS queue URL for order processing"
  value       = aws_sqs_queue.order_processing.url
}

output "sqs_queue_arn" {
  description = "SQS queue ARN"
  value       = aws_sqs_queue.order_processing.arn
}

output "sns_topic_arn" {
  description = "SNS topic ARN for order notifications"
  value       = aws_sns_topic.order_notifications.arn
}

output "secret_arn" {
  description = "Secrets Manager secret ARN for DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}
