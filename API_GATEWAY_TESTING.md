# API Gateway + Step Functions Testing Guide

## Quick Start

### Get Your API Endpoint

After deploying with Terraform:

```bash
cd terraform
terraform output workflow_api_url
```

### Test the Workflow

```bash
curl -X POST <YOUR_API_URL> \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "ORDER-12345",
    "productId": "PROD-001",
    "quantity": 2,
    "amount": 99.99,
    "paymentMethod": "credit_card"
  }'
```

## Test Scenarios

### 1. Successful Order (Happy Path)

**Request:**

```bash
curl -X POST https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/workflow/start \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "ORDER-SUCCESS-001",
    "productId": "PROD-001",
    "quantity": 2,
    "amount": 99.99,
    "paymentMethod": "credit_card"
  }'
```

**Expected Response:**

```json
{
  "executionArn": "arn:aws:states:us-east-1:ACCOUNT:execution:prod-order-workflow:uuid",
  "startDate": "2023-12-17T03:13:30.123Z",
  "message": "Workflow execution started successfully"
}
```

**Workflow Flow:**

1. Wait 3 seconds
2. Payment approved (amount < $1000) ✓
3. Inventory check (random, likely in stock) ✓
4. Shipment created ✓
5. Execution succeeds

### 2. Payment Failure

**Request:**

```bash
curl -X POST https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/workflow/start \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "ORDER-FAIL-PAYMENT",
    "productId": "PROD-002",
    "quantity": 1,
    "amount": 1500.00,
    "paymentMethod": "credit_card"
  }'
```

**Workflow Flow:**

1. Wait 3 seconds
2. Payment declined (amount >= $1000) ✗
3. Execution fails with "Payment failed"

### 3. Out of Stock

**Request:**

```bash
curl -X POST https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/workflow/start \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "ORDER-FAIL-STOCK",
    "productId": "PROD-003",
    "quantity": 150,
    "amount": 299.99,
    "paymentMethod": "credit_card"
  }'
```

**Workflow Flow:**

1. Wait 3 seconds
2. Payment approved ✓
3. Inventory check (random stock likely < 150) ✗
4. Execution fails with "Item out of stock"

## Monitoring Execution

### View in AWS Console

1. Go to Step Functions console
2. Click on `prod-order-workflow` state machine
3. Find your execution by ARN (from API response)
4. View execution graph and event history

### Check with AWS CLI

```bash
# Describe execution
aws stepfunctions describe-execution \
  --execution-arn <ARN_FROM_RESPONSE>

# Get execution history
aws stepfunctions get-execution-history \
  --execution-arn <ARN_FROM_RESPONSE> \
  --max-results 50
```

### CloudWatch Logs

```bash
# Payment Lambda logs
aws logs tail /aws/lambda/prod-payment-lambda --follow

# Inventory Lambda logs
aws logs tail /aws/lambda/prod-inventory-lambda --follow

# Shipment Lambda logs
aws logs tail /aws/lambda/prod-shipment-lambda --follow

# Step Functions logs
aws logs tail /aws/stepfunctions/prod-order-workflow --follow
```

## Deployment Steps

### 1. Build Docker Images

```bash
# Authenticate with ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  016829298884.dkr.ecr.us-east-1.amazonaws.com

# Payment Service
cd services/payment_service
docker build -t payment-service .
docker tag payment-service:latest \
  016829298884.dkr.ecr.us-east-1.amazonaws.com/serverless-ecommerce-dev-payment:latest
docker push \
  016829298884.dkr.ecr.us-east-1.amazonaws.com/serverless-ecommerce-dev-payment:latest

# Inventory Service
cd ../inventory_service
docker build -t inventory-service .
docker tag inventory-service:latest \
  016829298884.dkr.ecr.us-east-1.amazonaws.com/serverless-ecommerce-dev-inventory:latest
docker push \
  016829298884.dkr.ecr.us-east-1.amazonaws.com/serverless-ecommerce-dev-inventory:latest

# Shipment Service
cd ../shipment_service
docker build -t shipment-service .
docker tag shipment-service:latest \
  016829298884.dkr.ecr.us-east-1.amazonaws.com/serverless-ecommerce-dev-shipment:latest
docker push \
  016829298884.dkr.ecr.us-east-1.amazonaws.com/serverless-ecommerce-dev-shipment:latest
```

### 2. Deploy with Terraform

```bash
cd ../../terraform
terraform init
terraform plan
terraform apply
```

### 3. Get Outputs

```bash
terraform output workflow_api_url
terraform output step_functions_state_machine_arn
```

## Troubleshooting

### API Gateway Returns 500 Error

**Check:**

- IAM role has `states:StartExecution` permission
- State machine ARN is correct
- Request body is valid JSON

### Execution Fails Immediately

**Check:**

- Lambda functions are deployed
- Lambda ARNs in state machine definition are correct
- Lambda execution roles have necessary permissions

### CORS Errors

**Solution:**
The API includes CORS headers. If still having issues:

- Verify `Access-Control-Allow-Origin` header
- Check browser console for specific CORS error
- Ensure OPTIONS method is working

### Go Module Download Timeout

If `go mod tidy` fails with timeout:

```bash
# Set Go proxy
export GOPROXY=https://proxy.golang.org,direct

# Or use direct mode
export GOPROXY=direct

# Then retry
go mod tidy
```

## Production Considerations

### Add Authentication

**API Key:**

```hcl
resource "aws_api_gateway_api_key" "workflow_key" {
  name = "workflow-api-key"
}

resource "aws_api_gateway_usage_plan" "workflow_plan" {
  name = "workflow-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.stage.stage_name
  }
}
```

**Cognito:**

- Add Cognito authorizer to API Gateway method
- Require JWT token in Authorization header

### Add Rate Limiting

```hcl
resource "aws_api_gateway_usage_plan" "workflow_plan" {
  throttle_settings {
    burst_limit = 100
    rate_limit  = 50
  }
}
```

### Add Request Validation

```hcl
resource "aws_api_gateway_request_validator" "workflow_validator" {
  rest_api_id           = aws_api_gateway_rest_api.api.id
  name                  = "workflow-request-validator"
  validate_request_body = true
}
```

## Mock Data Behavior Reference

| Service       | Success Condition         | Returns                                          |
| ------------- | ------------------------- | ------------------------------------------------ |
| **Payment**   | amount < $1000            | `paymentStatus: "SUCCESS"`, `transactionId`      |
| **Inventory** | random(0-100) >= quantity | `inStock: true`, `availableStock`                |
| **Shipment**  | Always succeeds           | `trackingNumber`, `carrier`, `estimatedDelivery` |
