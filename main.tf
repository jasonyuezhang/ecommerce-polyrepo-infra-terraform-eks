locals {
  cluster_name = "${var.project_name}-${var.environment}-eks"

  tags = {
    Cluster     = local.cluster_name
    Environment = var.environment
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  name                 = "${var.project_name}-${var.environment}-vpc"
  cidr                 = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  cluster_name         = local.cluster_name

  tags = local.tags
}

# EKS Module - using terraform-aws-modules/eks/aws
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  # EKS Managed Node Group
  eks_managed_node_groups = {
    default = {
      name           = "${local.cluster_name}-node-group"
      instance_types = var.node_instance_types

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      labels = {
        Environment = var.environment
      }

      tags = local.tags
    }
  }

  tags = local.tags
}
