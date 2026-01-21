#!/bin/bash
# Test LocalStack AWS services

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "🧪 Testing LocalStack AWS services..."
echo "================================"

# Check if LocalStack is running
if ! curl -s http://localhost:4566/_localstack/health > /dev/null 2>&1; then
    echo "❌ Error: LocalStack is not running. Please start it first:"
    echo "  ./scripts/start-localstack.sh"
    exit 1
fi

# Set AWS credentials for LocalStack
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_ENDPOINT_URL="http://localhost:4566"

echo ""
echo "📊 Checking LocalStack health..."
curl -s http://localhost:4566/_localstack/health | jq '.'

echo ""
echo "================================"
echo "Testing AWS Services..."
echo "================================"

# Test S3
echo ""
echo "📦 Testing S3..."
if aws --endpoint-url=$AWS_ENDPOINT_URL s3 ls 2>/dev/null; then
    echo "✅ S3 is accessible"
    echo "Buckets:"
    aws --endpoint-url=$AWS_ENDPOINT_URL s3 ls | sed 's/^/  /'
else
    echo "⚠️  No S3 buckets found (this is OK if not deployed yet)"
fi

# Test DynamoDB
echo ""
echo "🗄️  Testing DynamoDB..."
if aws --endpoint-url=$AWS_ENDPOINT_URL dynamodb list-tables 2>/dev/null; then
    tables=$(aws --endpoint-url=$AWS_ENDPOINT_URL dynamodb list-tables --query 'TableNames' --output text)
    if [ -n "$tables" ]; then
        echo "✅ DynamoDB is accessible"
        echo "Tables:"
        echo "$tables" | tr '\t' '\n' | sed 's/^/  /'
    else
        echo "⚠️  No DynamoDB tables found (this is OK if not deployed yet)"
    fi
else
    echo "❌ DynamoDB is not accessible"
fi

# Test SQS
echo ""
echo "📨 Testing SQS..."
if aws --endpoint-url=$AWS_ENDPOINT_URL sqs list-queues 2>/dev/null; then
    queues=$(aws --endpoint-url=$AWS_ENDPOINT_URL sqs list-queues --query 'QueueUrls' --output text)
    if [ -n "$queues" ]; then
        echo "✅ SQS is accessible"
        echo "Queues:"
        echo "$queues" | tr '\t' '\n' | sed 's/^/  /'
    else
        echo "⚠️  No SQS queues found (this is OK if not deployed yet)"
    fi
else
    echo "❌ SQS is not accessible"
fi

# Test SNS
echo ""
echo "📬 Testing SNS..."
if aws --endpoint-url=$AWS_ENDPOINT_URL sns list-topics 2>/dev/null; then
    topics=$(aws --endpoint-url=$AWS_ENDPOINT_URL sns list-topics --query 'Topics[*].TopicArn' --output text)
    if [ -n "$topics" ]; then
        echo "✅ SNS is accessible"
        echo "Topics:"
        echo "$topics" | tr '\t' '\n' | sed 's/^/  /'
    else
        echo "⚠️  No SNS topics found (this is OK if not deployed yet)"
    fi
else
    echo "❌ SNS is not accessible"
fi

# Test Secrets Manager
echo ""
echo "🔐 Testing Secrets Manager..."
if aws --endpoint-url=$AWS_ENDPOINT_URL secretsmanager list-secrets 2>/dev/null; then
    secrets=$(aws --endpoint-url=$AWS_ENDPOINT_URL secretsmanager list-secrets --query 'SecretList[*].Name' --output text)
    if [ -n "$secrets" ]; then
        echo "✅ Secrets Manager is accessible"
        echo "Secrets:"
        echo "$secrets" | tr '\t' '\n' | sed 's/^/  /'
    else
        echo "⚠️  No secrets found (this is OK if not deployed yet)"
    fi
else
    echo "❌ Secrets Manager is not accessible"
fi

echo ""
echo "================================"
echo "✅ LocalStack testing complete!"
echo ""
echo "To deploy infrastructure:"
echo "  ./scripts/deploy-localstack.sh"
echo ""
echo "LocalStack UI: http://localhost:8888"
echo "================================"
