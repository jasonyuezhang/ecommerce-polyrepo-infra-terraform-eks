# EKS Infrastructure with Terraform

Minimal Terraform configuration for deploying an Amazon EKS cluster with VPC.

## Overview

This repository contains Terraform configurations to deploy:
- VPC with public and private subnets
- EKS cluster with managed node groups
- Required IAM roles and security groups

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
