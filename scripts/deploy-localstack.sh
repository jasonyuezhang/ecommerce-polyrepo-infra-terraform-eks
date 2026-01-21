#!/bin/bash
# Deploy infrastructure to LocalStack

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "🚀 Deploying infrastructure to LocalStack..."
echo "================================"

# Check if LocalStack is running
if ! curl -s http://localhost:4566/_localstack/health > /dev/null 2>&1; then
    echo "❌ Error: LocalStack is not running. Please start it first:"
    echo "  ./scripts/start-localstack.sh"
    exit 1
fi

# Navigate to project root
cd "${PROJECT_ROOT}"

# Set environment variables for LocalStack
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"

# Create a temporary directory for LocalStack Terraform
LOCALSTACK_DIR="${PROJECT_ROOT}/.localstack-terraform"
mkdir -p "${LOCALSTACK_DIR}"

# Copy the LocalStack configuration
cp "${PROJECT_ROOT}/localstack-main.tf" "${LOCALSTACK_DIR}/"

# Navigate to LocalStack directory
cd "${LOCALSTACK_DIR}"

# Initialize Terraform
echo "Initializing Terraform for LocalStack..."
terraform init

# Plan the deployment
echo ""
echo "Planning Terraform deployment..."
terraform plan -out=localstack.tfplan

# Ask for confirmation
echo ""
read -p "Do you want to apply this plan? (yes/no): " confirm

if [ "$confirm" = "yes" ]; then
    echo ""
    echo "Applying Terraform configuration..."
    terraform apply localstack.tfplan
    rm -f localstack.tfplan

    echo ""
    echo "================================"
    echo "✅ Infrastructure deployed to LocalStack!"
    echo ""
    echo "To view created resources:"
    echo "  cd ${LOCALSTACK_DIR} && terraform output"
    echo ""
    echo "LocalStack endpoint: http://localhost:4566"
    echo "================================"
else
    echo "Deployment cancelled"
    rm -f localstack.tfplan
    exit 0
fi
