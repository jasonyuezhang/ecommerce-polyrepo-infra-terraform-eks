# LocalStack Provider Configuration
# This file is used when deploying to LocalStack for local development

# Provider configuration for LocalStack
# To use this, set the environment variable: TF_VAR_use_localstack=true
variable "use_localstack" {
  description = "Flag to enable LocalStack endpoints"
  type        = bool
  default     = false
}

locals {
  # LocalStack endpoint configuration
  localstack_endpoint = "http://localhost:4566"

  # Override AWS endpoints when using LocalStack
  aws_endpoints = var.use_localstack ? {
    s3             = local.localstack_endpoint
    dynamodb       = local.localstack_endpoint
    sqs            = local.localstack_endpoint
    sns            = local.localstack_endpoint
    lambda         = local.localstack_endpoint
    cloudwatch     = local.localstack_endpoint
    logs           = local.localstack_endpoint
    iam            = local.localstack_endpoint
    sts            = local.localstack_endpoint
    secretsmanager = local.localstack_endpoint
    ssm            = local.localstack_endpoint
    ecr            = local.localstack_endpoint
    ecs            = local.localstack_endpoint
    apigateway     = local.localstack_endpoint
    cloudformation = local.localstack_endpoint
    ec2            = local.localstack_endpoint
    eks            = local.localstack_endpoint
  } : {}
}

# Example: S3 bucket for application assets
resource "aws_s3_bucket" "app_assets" {
  count  = var.use_localstack ? 1 : 0
  bucket = "${var.project_name}-${var.environment}-assets"

  tags = local.tags
}

# Example: DynamoDB table for session storage
resource "aws_dynamodb_table" "sessions" {
  count        = var.use_localstack ? 1 : 0
  name         = "${var.project_name}-${var.environment}-sessions"
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

# Example: SQS queue for async processing
resource "aws_sqs_queue" "order_processing" {
  count                     = var.use_localstack ? 1 : 0
  name                      = "${var.project_name}-${var.environment}-order-processing"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 10

  tags = local.tags
}

# Example: SNS topic for notifications
resource "aws_sns_topic" "order_notifications" {
  count = var.use_localstack ? 1 : 0
  name  = "${var.project_name}-${var.environment}-order-notifications"

  tags = local.tags
}

# Example: Secrets Manager for sensitive configuration
resource "aws_secretsmanager_secret" "db_credentials" {
  count       = var.use_localstack ? 1 : 0
  name        = "${var.project_name}-${var.environment}-db-credentials"
  description = "Database credentials for ${var.environment} environment"

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  count     = var.use_localstack ? 1 : 0
  secret_id = aws_secretsmanager_secret.db_credentials[0].id
  secret_string = jsonencode({
    username = "postgres"
    password = "postgres"
    database = "ecommerce"
    host     = "postgres"
    port     = 5432
  })
}

# Outputs for LocalStack resources
output "localstack_s3_bucket" {
  description = "S3 bucket name for application assets"
  value       = var.use_localstack ? aws_s3_bucket.app_assets[0].id : null
}

output "localstack_dynamodb_table" {
  description = "DynamoDB table name for sessions"
  value       = var.use_localstack ? aws_dynamodb_table.sessions[0].name : null
}

output "localstack_sqs_queue_url" {
  description = "SQS queue URL for order processing"
  value       = var.use_localstack ? aws_sqs_queue.order_processing[0].url : null
}

output "localstack_sns_topic_arn" {
  description = "SNS topic ARN for order notifications"
  value       = var.use_localstack ? aws_sns_topic.order_notifications[0].arn : null
}

output "localstack_secret_arn" {
  description = "Secrets Manager secret ARN for DB credentials"
  value       = var.use_localstack ? aws_secretsmanager_secret.db_credentials[0].arn : null
}
