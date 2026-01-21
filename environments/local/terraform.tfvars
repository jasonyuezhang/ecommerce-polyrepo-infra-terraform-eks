# Local Environment Configuration for LocalStack
project_name = "ecommerce"
environment  = "local"

# LocalStack uses mock regions, us-east-1 is the default
aws_region = "us-east-1"

# VPC Configuration (simulated for LocalStack)
vpc_cidr             = "10.100.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
private_subnet_cidrs = ["10.100.1.0/24", "10.100.2.0/24"]
public_subnet_cidrs  = ["10.100.101.0/24", "10.100.102.0/24"]

# EKS Configuration (minimal for local testing)
cluster_version = "1.28"
enable_cluster_creator_admin_permissions = true

# Node Group Configuration (minimal for local)
node_instance_types = ["t3.small"]
node_min_size       = 1
node_max_size       = 2
node_desired_size   = 1

# LocalStack specific settings
use_localstack = true
