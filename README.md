# EKS Infrastructure with Terraform

Minimal Terraform configuration for deploying an Amazon EKS cluster with VPC.

## 🎯 About This Repository

This repository is part of the **ecommerce-polyrepo** project - a polyrepo setup designed for testing the [Propel](https://propel.us) code review feature across multiple microservices.

### Role in Microservices Architecture

This repository provides the **production-grade Kubernetes infrastructure** for deploying all microservices to AWS EKS:

```
┌─────────────────────────────────────────┐
│         AWS Cloud Infrastructure         │
│  ┌────────────────────────────────────┐ │
│  │          EKS Cluster                │ │
│  │  ┌──────────┐  ┌──────────────┐   │ │
│  │  │ Frontend │  │ API Gateway  │   │ │
│  │  │(Next.js) │  │   (Go/Gin)   │   │ │
│  │  └──────────┘  └──────────────┘   │ │
│  │  ┌──────────┐  ┌──────────────┐   │ │
│  │  │   User   │  │   Listing    │   │ │
│  │  │ Service  │  │   Service    │   │ │
│  │  └──────────┘  └──────────────┘   │ │
│  │  ┌──────────┐  ┌──────────────┐   │ │
│  │  │Inventory │  │  PostgreSQL  │   │ │
│  │  │ Service  │  │    Redis     │   │ │
│  │  └──────────┘  └──────────────┘   │ │
│  └────────────────────────────────────┘ │
│                                          │
│  Provisioned by Terraform [THIS REPO]   │
└─────────────────────────────────────────┘
```

### Quick Start (Standalone Testing)

To test infrastructure provisioning locally without AWS costs:

```bash
# 1. Ensure prerequisites are installed
terraform -version
docker --version

# 2. Start LocalStack (AWS emulator)
./scripts/start-localstack.sh

# 3. Deploy infrastructure to LocalStack
./scripts/deploy-localstack.sh

# 4. Test deployed services
./scripts/test-localstack.sh

# 5. Cleanup when done
./scripts/cleanup-localstack.sh

# For detailed LocalStack usage, see LOCALSTACK.md
```

**Note:** For local development, use the `local-k8s/` directory in the [parent polyrepo](https://github.com/jasonyuezhang/ecommerce-polyrepo) which provides Minikube setup. This repo is for production AWS EKS deployment with Terraform.

---

## Overview

This repository contains Terraform configurations to deploy:
- VPC with public and private subnets
- EKS cluster with managed node groups
- Required IAM roles and security groups
- Application Load Balancer for REST and GraphQL gateways
- Target groups for service routing

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                          VPC                                 │
│  ┌─────────────────┐              ┌─────────────────┐       │
│  │  Public Subnet  │              │  Public Subnet  │       │
│  │     (AZ-a)      │              │     (AZ-b)      │       │
│  └─────────────────┘              └─────────────────┘       │
│  ┌─────────────────┐              ┌─────────────────┐       │
│  │ Private Subnet  │              │ Private Subnet  │       │
│  │     (AZ-a)      │──── EKS ────│     (AZ-b)      │       │
│  └─────────────────┘              └─────────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

- Terraform >= 1.3.0
- AWS CLI configured with appropriate credentials
- kubectl for cluster access

## Local Development with LocalStack

For local testing and validation without deploying to AWS, you can use LocalStack to emulate AWS services locally.

### Quick Start with LocalStack

```bash
# Start LocalStack
./scripts/start-localstack.sh

# Deploy infrastructure to LocalStack
./scripts/deploy-localstack.sh

# Test deployed services
./scripts/test-localstack.sh

# Cleanup when done
./scripts/cleanup-localstack.sh
```

📖 **See [LOCALSTACK.md](./LOCALSTACK.md) for detailed LocalStack usage guide**

LocalStack provides:
- ✅ Local AWS service emulation (S3, DynamoDB, SQS, SNS, etc.)
- ✅ No AWS costs for development
- ✅ Fast iteration and testing
- ✅ AWS CLI compatible interface
- ✅ Data persistence between restarts

## Usage

### Initialize Terraform

```bash
terraform init
```

### Deploy to Development

```bash
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

### Deploy to Production

```bash
terraform plan -var-file=environments/prod/terraform.tfvars
terraform apply -var-file=environments/prod/terraform.tfvars
```

### Configure kubectl

After deployment, configure kubectl access:

```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

## Module References

This configuration uses the following community modules:
- [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws)
- [terraform-aws-modules/eks/aws](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws)

## Outputs

| Output | Description |
|--------|-------------|
| cluster_endpoint | EKS cluster API endpoint |
| cluster_name | EKS cluster name |
| cluster_security_group_id | Security group ID attached to the EKS cluster |
| vpc_id | VPC ID |

## Cleanup

```bash
terraform destroy -var-file=environments/<env>/terraform.tfvars
```
