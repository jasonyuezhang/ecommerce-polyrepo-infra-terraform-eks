# LocalStack Development Environment

This guide explains how to use LocalStack for local AWS service emulation and validation.

## What is LocalStack?

[LocalStack](https://github.com/localstack/localstack) is a fully functional local AWS cloud stack that allows you to develop and test your AWS applications offline. It emulates AWS services like S3, DynamoDB, SQS, SNS, Lambda, and many more.

## Prerequisites

- Docker and Docker Compose installed
- Terraform >= 1.3.0
- AWS CLI v2
- `jq` (for testing scripts)

### Install AWS CLI

```bash
# macOS
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Install jq

```bash
# macOS
brew install jq

# Linux
sudo apt-get install jq  # Debian/Ubuntu
sudo yum install jq      # RHEL/CentOS
```

## Quick Start

### 1. Start LocalStack

```bash
./scripts/start-localstack.sh
```

This will:
- Start LocalStack container on port 4566
- Wait for services to be ready
- Display connection information

### 2. Verify LocalStack is Running

```bash
./scripts/test-localstack.sh
```

This will test connectivity to various AWS services and list any existing resources.

### 3. Deploy Infrastructure

```bash
./scripts/deploy-localstack.sh
```

This will:
- Initialize Terraform if needed
- Create a deployment plan
- Apply the configuration to LocalStack

### 4. Verify Deployed Resources

```bash
# View Terraform outputs
terraform output

# Test services again
./scripts/test-localstack.sh
```

### 5. Cleanup

```bash
./scripts/cleanup-localstack.sh
```

This will:
- Destroy Terraform resources
- Stop LocalStack containers
- Optionally remove persisted data

## Services Included

The LocalStack setup includes the following AWS services:

- **S3** - Object storage for application assets
- **DynamoDB** - NoSQL database for session storage
- **SQS** - Message queue for async processing
- **SNS** - Pub/sub notifications
- **Lambda** - Serverless functions
- **CloudWatch/Logs** - Monitoring and logging
- **IAM/STS** - Identity and access management
- **Secrets Manager** - Sensitive configuration storage
- **SSM Parameter Store** - Configuration management
- **ECR** - Container registry
- **ECS** - Container orchestration
- **API Gateway** - API management
- **CloudFormation** - Infrastructure as code

## Example Resources

The Terraform configuration creates example resources for common use cases:

### S3 Bucket
```bash
# List buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# Upload a file
aws --endpoint-url=http://localhost:4566 s3 cp test.txt s3://ecommerce-local-assets/

# Download a file
aws --endpoint-url=http://localhost:4566 s3 cp s3://ecommerce-local-assets/test.txt downloaded.txt
```

### DynamoDB Table
```bash
# List tables
aws --endpoint-url=http://localhost:4566 dynamodb list-tables

# Put an item
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
  --table-name ecommerce-local-sessions \
  --item '{
    "sessionId": {"S": "test-session-123"},
    "userId": {"S": "user-456"},
    "expiresAt": {"N": "1704067200"}
  }'

# Get an item
aws --endpoint-url=http://localhost:4566 dynamodb get-item \
  --table-name ecommerce-local-sessions \
  --key '{"sessionId": {"S": "test-session-123"}}'
```

### SQS Queue
```bash
# Get queue URL
QUEUE_URL=$(aws --endpoint-url=http://localhost:4566 sqs get-queue-url \
  --queue-name ecommerce-local-order-processing \
  --query 'QueueUrl' --output text)

# Send a message
aws --endpoint-url=http://localhost:4566 sqs send-message \
  --queue-url $QUEUE_URL \
  --message-body '{"orderId": "order-789", "status": "pending"}'

# Receive messages
aws --endpoint-url=http://localhost:4566 sqs receive-message \
  --queue-url $QUEUE_URL
```

### SNS Topic
```bash
# Get topic ARN
TOPIC_ARN=$(aws --endpoint-url=http://localhost:4566 sns list-topics \
  --query 'Topics[0].TopicArn' --output text)

# Publish a message
aws --endpoint-url=http://localhost:4566 sns publish \
  --topic-arn $TOPIC_ARN \
  --message '{"type": "order_placed", "orderId": "order-789"}'
```

### Secrets Manager
```bash
# Get secret value
aws --endpoint-url=http://localhost:4566 secretsmanager get-secret-value \
  --secret-id ecommerce-local-db-credentials \
  --query 'SecretString' --output text | jq '.'
```

## LocalStack Web UI

LocalStack provides a web-based UI for easier resource management:

- **LocalStack Pro**: Includes full-featured Web UI at https://app.localstack.cloud
- **Community Edition**: Use AWS CLI with `--endpoint-url=http://localhost:4566`

For visual inspection in the community edition, you can:
- Use AWS CLI commands to list and inspect resources
- Make direct HTTP requests to http://localhost:4566
- Use third-party tools like AWS CLI, Terraform, or SDK clients

## Configuration

### Environment Variables

When using LocalStack, set these environment variables:

```bash
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_ENDPOINT_URL="http://localhost:4566"
```

### Terraform Variables

The local environment uses these settings (in `environments/local/terraform.tfvars`):

```hcl
project_name     = "ecommerce"
environment      = "local"
use_localstack   = true
```

## Troubleshooting

### LocalStack won't start

```bash
# Check Docker is running
docker info

# Check logs
docker-compose -f docker-compose.localstack.yml logs localstack

# Restart LocalStack
docker-compose -f docker-compose.localstack.yml restart
```

### Terraform errors

```bash
# Verify LocalStack is running
curl http://localhost:4566/_localstack/health

# Re-initialize Terraform
rm -rf .terraform .terraform.lock.hcl
terraform init

# Check AWS credentials are set
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY
```

### Services not accessible

```bash
# Verify endpoint configuration
env | grep AWS

# Test specific service
aws --endpoint-url=http://localhost:4566 s3 ls

# Check LocalStack logs for errors
docker-compose -f docker-compose.localstack.yml logs -f localstack
```

### Reset everything

```bash
# Complete cleanup
./scripts/cleanup-localstack.sh

# Remove all data
rm -rf localstack-data .terraform terraform.tfstate*

# Start fresh
./scripts/start-localstack.sh
./scripts/deploy-localstack.sh
```

## Data Persistence

LocalStack data is persisted in the `localstack-data` directory. This means:
- Resources survive container restarts
- Data is preserved between sessions
- You can backup/restore the entire state

To start with a clean slate:
```bash
docker-compose -f docker-compose.localstack.yml down -v
rm -rf localstack-data
```

## Integration with Application Services

To configure your application services to use LocalStack:

### Environment Variables

Add to your service configuration:

```yaml
environment:
  - AWS_ACCESS_KEY_ID=test
  - AWS_SECRET_ACCESS_KEY=test
  - AWS_REGION=us-east-1
  - AWS_ENDPOINT_URL=http://localstack:4566
```

### Docker Compose

If running services via Docker Compose, add them to the LocalStack network:

```yaml
services:
  your-service:
    networks:
      - localstack-network

networks:
  localstack-network:
    external: true
```

## Best Practices

1. **Always test infrastructure changes locally first**
   - Deploy to LocalStack before AWS
   - Validate resources work as expected
   - Test IAM policies and permissions

2. **Use environment-specific configurations**
   - Keep LocalStack configs in `environments/local/`
   - Use variables for environment-specific values
   - Don't commit sensitive data

3. **Clean up regularly**
   - Remove unused resources
   - Clear old Terraform state files
   - Reset LocalStack periodically

4. **Monitor resource usage**
   - LocalStack can consume significant memory
   - Limit services to what you actually need
   - Stop LocalStack when not in use

## Advanced Usage

### Custom Service Configuration

Edit `docker-compose.localstack.yml` to:
- Add/remove services
- Adjust port mappings
- Configure persistence
- Set resource limits

### Multiple Environments

Create additional environment configs:

```bash
cp environments/local/terraform.tfvars environments/local-staging/terraform.tfvars
# Edit as needed
terraform apply -var-file=environments/local-staging/terraform.tfvars
```

### CI/CD Integration

Use LocalStack in CI pipelines:

```yaml
# Example GitHub Actions
- name: Start LocalStack
  run: docker-compose -f docker-compose.localstack.yml up -d

- name: Wait for LocalStack
  run: |
    while ! curl -s http://localhost:4566/_localstack/health | grep -q available; do
      sleep 1
    done

- name: Test Infrastructure
  run: ./scripts/test-localstack.sh
```

## Resources

- [LocalStack Documentation](https://docs.localstack.cloud/)
- [LocalStack GitHub](https://github.com/localstack/localstack)
- [Terraform LocalStack Examples](https://github.com/localstack/localstack-terraform-samples)
- [AWS CLI with LocalStack](https://docs.localstack.cloud/user-guide/integrations/aws-cli/)

## Support

For issues with:
- **LocalStack itself**: Check [LocalStack GitHub Issues](https://github.com/localstack/localstack/issues)
- **This configuration**: Open an issue in this repository
- **Terraform**: Consult [Terraform Documentation](https://www.terraform.io/docs)
