# Production Environment Configuration

aws_region   = "us-east-1"
environment  = "prod"
project_name = "ecommerce"

# VPC Configuration - larger CIDR for production
vpc_cidr             = "10.1.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
private_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
public_subnet_cidrs  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

# EKS Configuration - production-grade sizing
cluster_version     = "1.29"
node_instance_types = ["t3.large", "t3.xlarge"]
node_desired_size   = 3
node_min_size       = 2
node_max_size       = 10

enable_cluster_creator_admin_permissions = true
