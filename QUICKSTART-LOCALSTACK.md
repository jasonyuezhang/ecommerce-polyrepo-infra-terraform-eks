# LocalStack Quick Start Guide

Get started with LocalStack in under 5 minutes!

## Prerequisites Check

```bash
# Verify Docker is running
docker --version

# Verify Terraform is installed
terraform --version

# Verify AWS CLI is installed
aws --version

# Optional: Verify jq for pretty JSON output
jq --version
```

## 🚀 Quick Start

### Option 1: Using Make (Recommended)

From the repository root:

```bash
# 1. Start LocalStack
make localstack-start

# 2. Deploy infrastructure
make localstack-deploy

# 3. Test services
make localstack-test

# 4. Cleanup when done
make localstack-cleanup
```

### Option 2: Using Scripts Directly

From the `infra-terraform-eks` directory:

```bash
# 1. Start LocalStack
./scripts/start-localstack.sh

# 2. Deploy infrastructure
./scripts/deploy-localstack.sh

# 3. Test services
./scripts/test-localstack.sh

# 4. Cleanup when done
./scripts/cleanup-localstack.sh
```

## ✅ Verify Installation

After deploying, verify resources were created:

```bash
# Set environment variables for AWS CLI
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"

# List S3 buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# List DynamoDB tables
aws --endpoint-url=http://localhost:4566 dynamodb list-tables

# List SQS queues
aws --endpoint-url=http://localhost:4566 sqs list-queues

# List SNS topics
aws --endpoint-url=http://localhost:4566 sns list-topics
```

## 🎯 Common Use Cases

### Test S3 Operations

```bash
# Create a test file
echo "Hello LocalStack!" > test.txt

# Upload to S3
aws --endpoint-url=http://localhost:4566 s3 cp test.txt s3://ecommerce-local-assets/

# List bucket contents
aws --endpoint-url=http://localhost:4566 s3 ls s3://ecommerce-local-assets/

# Download file
aws --endpoint-url=http://localhost:4566 s3 cp s3://ecommerce-local-assets/test.txt downloaded.txt

# Verify contents
cat downloaded.txt
```

### Test DynamoDB Operations

```bash
# Put an item
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
  --table-name ecommerce-local-sessions \
  --item '{
    "sessionId": {"S": "test-123"},
    "userId": {"S": "user-456"},
    "data": {"S": "{\"cart\": [\"item1\", \"item2\"]}"},
    "expiresAt": {"N": "'$(date -d '+1 day' +%s)'"}
  }'

# Get item
aws --endpoint-url=http://localhost:4566 dynamodb get-item \
  --table-name ecommerce-local-sessions \
  --key '{"sessionId": {"S": "test-123"}}' | jq '.Item'

# Scan table
aws --endpoint-url=http://localhost:4566 dynamodb scan \
  --table-name ecommerce-local-sessions | jq '.Items'
```

### Test SQS Operations

```bash
# Get queue URL
QUEUE_URL=$(aws --endpoint-url=http://localhost:4566 sqs get-queue-url \
  --queue-name ecommerce-local-order-processing \
  --query 'QueueUrl' --output text)

echo "Queue URL: $QUEUE_URL"

# Send message
aws --endpoint-url=http://localhost:4566 sqs send-message \
  --queue-url $QUEUE_URL \
  --message-body '{"orderId": "ORD-123", "amount": 99.99}'

# Receive message
aws --endpoint-url=http://localhost:4566 sqs receive-message \
  --queue-url $QUEUE_URL | jq '.'

# Get queue attributes
aws --endpoint-url=http://localhost:4566 sqs get-queue-attributes \
  --queue-url $QUEUE_URL \
  --attribute-names All | jq '.Attributes'
```

### Test SNS Operations

```bash
# Get topic ARN
TOPIC_ARN=$(aws --endpoint-url=http://localhost:4566 sns list-topics \
  --query 'Topics[0].TopicArn' --output text)

echo "Topic ARN: $TOPIC_ARN"

# Publish message
aws --endpoint-url=http://localhost:4566 sns publish \
  --topic-arn $TOPIC_ARN \
  --subject "Test Order Notification" \
  --message '{"event": "order_placed", "orderId": "ORD-123"}'

# Subscribe to topic (email)
aws --endpoint-url=http://localhost:4566 sns subscribe \
  --topic-arn $TOPIC_ARN \
  --protocol email \
  --notification-endpoint test@example.com

# List subscriptions
aws --endpoint-url=http://localhost:4566 sns list-subscriptions-by-topic \
  --topic-arn $TOPIC_ARN | jq '.'
```

### Test Secrets Manager

```bash
# Get secret
aws --endpoint-url=http://localhost:4566 secretsmanager get-secret-value \
  --secret-id ecommerce-local-db-credentials \
  --query 'SecretString' --output text | jq '.'

# Update secret
aws --endpoint-url=http://localhost:4566 secretsmanager update-secret \
  --secret-id ecommerce-local-db-credentials \
  --secret-string '{"username":"postgres","password":"newpassword","database":"ecommerce","host":"postgres","port":5432}'

# List secrets
aws --endpoint-url=http://localhost:4566 secretsmanager list-secrets | jq '.SecretList'
```

## 📊 View Resources

You can view and manage resources using:
1. AWS CLI with `--endpoint-url=http://localhost:4566`
2. LocalStack Web UI at https://app.localstack.cloud (requires LocalStack Pro)
3. Direct API calls to http://localhost:4566

## 🔍 Troubleshooting

### LocalStack won't start

```bash
# Check Docker
docker ps

# Check logs
make localstack-logs
# or
cd infra-terraform-eks && docker-compose -f docker-compose.localstack.yml logs -f
```

### Terraform apply fails

```bash
# Verify LocalStack is running
curl http://localhost:4566/_localstack/health

# Check AWS credentials are set
env | grep AWS

# Re-initialize Terraform
cd infra-terraform-eks
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### Can't access services

```bash
# Make sure to set endpoint URL
export AWS_ENDPOINT_URL="http://localhost:4566"

# Or use --endpoint-url flag
aws --endpoint-url=http://localhost:4566 s3 ls
```

## 🧹 Cleanup

### Stop LocalStack but keep data

```bash
make localstack-stop
```

### Full cleanup (removes all data)

```bash
make localstack-cleanup
```

### Manual cleanup

```bash
cd infra-terraform-eks
docker-compose -f docker-compose.localstack.yml down -v
rm -rf localstack-data .terraform terraform.tfstate*
```

## 📚 Next Steps

1. **Read the full guide**: [LOCALSTACK.md](./LOCALSTACK.md)
2. **Integrate with your app**: Configure app services to use LocalStack
3. **Add custom resources**: Modify `localstack-provider.tf`
4. **CI/CD integration**: Use LocalStack in your pipelines

## 💡 Tips

- **Persistence**: LocalStack data persists in `localstack-data/` directory
- **Multiple terminals**: Run LocalStack in one terminal, tests in another
- **Environment aliases**: Add aliases to your shell config:
  ```bash
  alias awslocal="aws --endpoint-url=http://localhost:4566"
  ```
- **Fast iteration**: LocalStack starts in ~10 seconds
- **Cost savings**: No AWS charges for development!

## 🆘 Need Help?

- Full documentation: [LOCALSTACK.md](./LOCALSTACK.md)
- LocalStack docs: https://docs.localstack.cloud/
- Run tests: `make localstack-test`
- Check logs: `make localstack-logs`

## ✨ Example Workflow

```bash
# Morning: Start LocalStack
make localstack-start

# Deploy your infrastructure
make localstack-deploy

# Develop and test your application all day
# (LocalStack keeps running)

# Evening: Stop LocalStack
make localstack-stop

# Next day: Start again (data persists!)
make localstack-start
```

Happy local AWS development! 🚀
