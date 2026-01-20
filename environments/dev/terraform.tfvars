# Development Environment Configuration

aws_region   = "us-east-1"
environment  = "dev"
project_name = "ecommerce"

# VPC Configuration
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]

# EKS Configuration
cluster_version     = "1.29"
node_instance_types = ["t3.medium"]
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 3

enable_cluster_creator_admin_permissions = true
