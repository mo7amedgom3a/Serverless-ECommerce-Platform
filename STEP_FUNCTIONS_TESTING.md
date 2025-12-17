# Step Functions Order Workflow - Testing Guide

This document provides instructions for testing the Step Functions order workflow orchestration.

## Overview

The Step Functions state machine orchestrates three Lambda functions to process e-commerce orders:

1. **Payment Processing** - Validates and processes payment
2. **Inventory Check** - Verifies product availability
3. **Shipment Creation** - Creates shipment and tracking information

## Architecture

```
Start → Wait (3s) → Process Payment → Payment Decision
                                            ↓
                                    [SUCCESS] → Check Inventory → Inventory Decision
                                            ↓                              ↓
                                    [FAILED]                      [IN STOCK] → Create Shipment → End
                                            ↓                              ↓
                                    Payment Failed (Fail)          [OUT OF STOCK]
                                                                           ↓
                                                                   Out of Stock (Fail)
```

## Test Scenarios

### Scenario 1: Successful Order (Happy Path)

**Input:**

```json
{
  "orderId": "ORDER-12345",
  "productId": "PROD-001",
  "quantity": 2,
  "amount": 99.99,
  "paymentMethod": "credit_card"
}
```

**Expected Flow:**

1. Wait 3 seconds
2. Process payment → SUCCESS (amount < 1000)
3. Check inventory → IN STOCK (random availability)
4. Create shipment → Tracking number generated
5. End with success

**Expected Output:**

```json
{
  "orderId": "ORDER-12345",
  "productId": "PROD-001",
  "quantity": 2,
  "amount": 99.99,
  "paymentStatus": "SUCCESS",
  "transactionId": "TXN-20231217010230-1234",
  "inStock": true,
  "availableStock": 50,
  "shipmentId": "SHIP-123456",
  "trackingNumber": "TRACK-20231217-12345",
  "carrier": "FedEx",
  "estimatedDelivery": "2023-12-24",
  "status": "CREATED"
}
```

### Scenario 2: Payment Failed

**Input:**

```json
{
  "orderId": "ORDER-12346",
  "productId": "PROD-002",
  "quantity": 1,
  "amount": 1500.0,
  "paymentMethod": "credit_card"
}
```

**Expected Flow:**

1. Wait 3 seconds
2. Process payment → FAILED (amount >= 1000)
3. Payment Failed (Fail state)

**Expected Result:** Execution fails with cause "Payment failed"

### Scenario 3: Out of Stock

**Input:**

```json
{
  "orderId": "ORDER-12347",
  "productId": "PROD-003",
  "quantity": 150,
  "amount": 299.99,
  "paymentMethod": "credit_card"
}
```

**Expected Flow:**

1. Wait 3 seconds
2. Process payment → SUCCESS
3. Check inventory → OUT OF STOCK (quantity > available stock)
4. Out of Stock (Fail state)

**Expected Result:** Execution fails with cause "Item out of stock"

## Testing via AWS Console

1. Navigate to AWS Step Functions console
2. Find the state machine: `{environment}-order-workflow`
3. Click "Start execution"
4. Paste one of the test inputs above
5. Click "Start execution"
6. Monitor the execution graph in real-time
7. Review the execution event history
8. Check CloudWatch Logs for detailed Lambda execution logs

## Testing via AWS CLI

```bash
# Start an execution
aws stepfunctions start-execution \
  --state-machine-arn arn:aws:states:us-east-1:ACCOUNT_ID:stateMachine:prod-order-workflow \
  --input '{"orderId":"ORDER-12345","productId":"PROD-001","quantity":2,"amount":99.99,"paymentMethod":"credit_card"}' \
  --name test-execution-1

# Describe execution
aws stepfunctions describe-execution \
  --execution-arn arn:aws:states:us-east-1:ACCOUNT_ID:execution:prod-order-workflow:test-execution-1

# Get execution history
aws stepfunctions get-execution-history \
  --execution-arn arn:aws:states:us-east-1:ACCOUNT_ID:execution:prod-order-workflow:test-execution-1
```

## Mock Data Behavior

### Payment Lambda

- **Success:** Amount < 1000
- **Failure:** Amount >= 1000
- Returns: `paymentStatus`, `transactionId`, `message`

### Inventory Lambda

- **In Stock:** Random stock level (0-100) >= requested quantity
- **Out of Stock:** Random stock level < requested quantity
- Returns: `inStock`, `availableStock`, `message`
- Passes through: `paymentStatus`, `transactionId`, `amount`

### Shipment Lambda

- Always succeeds if reached
- Generates: `shipmentId`, `trackingNumber`, `carrier`, `estimatedDelivery`
- Passes through: `amount`, `transactionId`

## CloudWatch Logs

Each Lambda function logs to:

- `/aws/lambda/{environment}-payment-lambda`
- `/aws/lambda/{environment}-inventory-lambda`
- `/aws/lambda/{environment}-shipment-lambda`

Step Functions logs to:

- `/aws/stepfunctions/{environment}-order-workflow`

## Troubleshooting

### Execution Fails Immediately

- Check IAM permissions for Step Functions role
- Verify Lambda ARNs in state machine definition
- Check Lambda function status (Active/Failed)

### Lambda Timeout

- Default timeout is 30 seconds
- Check CloudWatch Logs for errors
- Verify Lambda has necessary permissions

### State Machine Not Found

- Run `terraform apply` to create resources
- Check Terraform outputs for state machine ARN
- Verify AWS region matches configuration

## Next Steps

1. **Build and Push Docker Images:**

   ```bash
   # Navigate to each service directory and build
   cd services/payment_service
   docker build -t payment-service .

   # Tag and push to ECR
   docker tag payment-service:latest ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/serverless-ecommerce-dev-payment:latest
   docker push ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/serverless-ecommerce-dev-payment:latest
   ```

2. **Deploy Infrastructure:**

   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

3. **Test Workflow:**
   Use the test scenarios above to validate the orchestration

4. **Monitor and Iterate:**
   - Review CloudWatch metrics
   - Analyze execution patterns
   - Optimize Lambda performance
   - Add error handling and retries
