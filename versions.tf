terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # LocalStack configuration - only used when use_localstack is true
  access_key = var.use_localstack ? "test" : null
  secret_key = var.use_localstack ? "test" : null

  # Skip credential validation for LocalStack
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack

  # LocalStack endpoints
  dynamic "endpoints" {
    for_each = var.use_localstack ? [1] : []
    content {
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
      ecr            = "http://localhost:4566"
      ecs            = "http://localhost:4566"
      apigateway     = "http://localhost:4566"
      cloudformation = "http://localhost:4566"
      ec2            = "http://localhost:4566"
      eks            = "http://localhost:4566"
    }
  }

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}
