#!/bin/bash
# Cleanup LocalStack resources and stop containers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "🧹 Cleaning up LocalStack..."
echo "================================"

# Navigate to project root
cd "${PROJECT_ROOT}"

# Destroy Terraform resources if they exist
if [ -f "terraform.tfstate" ] || [ -f "terraform.tfstate.backup" ]; then
    echo "Destroying Terraform resources..."

    export AWS_ACCESS_KEY_ID="test"
    export AWS_SECRET_ACCESS_KEY="test"
    export AWS_DEFAULT_REGION="us-east-1"
    export TF_VAR_use_localstack=true

    terraform destroy -var-file=environments/local/terraform.tfvars -auto-approve || true
fi

# Stop and remove LocalStack containers
echo ""
echo "Stopping LocalStack containers..."
docker-compose -f docker-compose.localstack.yml down -v

# Optional: Remove persisted data
read -p "Do you want to remove persisted LocalStack data? (yes/no): " remove_data

if [ "$remove_data" = "yes" ]; then
    echo "Removing LocalStack data..."
    rm -rf localstack-data
    echo "✅ LocalStack data removed"
fi

# Clean up Terraform files
echo ""
read -p "Do you want to remove Terraform state files? (yes/no): " remove_tf

if [ "$remove_tf" = "yes" ]; then
    echo "Removing Terraform files..."
    rm -rf .terraform
    rm -f .terraform.lock.hcl
    rm -f terraform.tfstate*
    rm -f localstack.tfplan
    echo "✅ Terraform files removed"
fi

echo ""
echo "================================"
echo "✅ LocalStack cleanup complete!"
echo "================================"
