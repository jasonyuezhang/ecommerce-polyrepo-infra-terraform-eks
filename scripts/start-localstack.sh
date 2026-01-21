#!/bin/bash
# Start LocalStack for local AWS service emulation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "🚀 Starting LocalStack..."
echo "================================"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: docker-compose is not installed. Please install it first."
    exit 1
fi

# Navigate to project root
cd "${PROJECT_ROOT}"

# Start LocalStack
echo "Starting LocalStack containers..."
docker-compose -f docker-compose.localstack.yml up -d

# Wait for LocalStack to be ready
echo "Waiting for LocalStack to be ready..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if curl -s http://localhost:4566/_localstack/health | grep -q '"s3": "available"'; then
        echo "✅ LocalStack is ready!"
        break
    fi

    attempt=$((attempt + 1))
    if [ $attempt -eq $max_attempts ]; then
        echo "❌ LocalStack failed to start after ${max_attempts} attempts"
        docker-compose -f docker-compose.localstack.yml logs localstack
        exit 1
    fi

    echo "Waiting... (attempt $attempt/$max_attempts)"
    sleep 2
done

echo ""
echo "================================"
echo "✅ LocalStack is running!"
echo ""
echo "Services available at: http://localhost:4566"
echo "LocalStack UI available at: http://localhost:8888"
echo ""
echo "To view logs:"
echo "  docker-compose -f docker-compose.localstack.yml logs -f"
echo ""
echo "To stop LocalStack:"
echo "  docker-compose -f docker-compose.localstack.yml down"
echo ""
echo "To deploy infrastructure:"
echo "  ./scripts/deploy-localstack.sh"
echo "================================"
