# Orders Service

Order management microservice with SNS notification integration, built with Python and FastAPI.

## 📋 Overview

The Orders Service handles order creation, management, and processing with automatic email notifications. It integrates with SNS to publish order events, triggering asynchronous email notifications through the Email Notifier service.

## 🏗️ Architecture

```
API Gateway → Lambda (FastAPI) → RDS MySQL
                ↓
            SNS Topic → SQS Queue → Email Notifier Lambda
                ↓
         Secrets Manager
```

### Technology Stack

- **Language**: Python 3.11
- **Framework**: FastAPI
- **ORM**: SQLAlchemy
- **Database**: AWS RDS MySQL
- **Messaging**: AWS SNS + SQS
- **Deployment**: AWS Lambda (Container)

## 📁 Project Structure

```
orders_service/
├── app/
│   ├── models/           # SQLAlchemy models
│   │   ├── order.py
│   │   └── order_item.py
│   ├── schemas/          # Pydantic schemas
│   │   ├── order.py
│   │   └── order_item.py
│   ├── repositories/     # Data access layer
│   │   └── order_repository.py
│   ├── services/         # Business logic
│   │   └── order_service.py
│   ├── routers/          # API routes
│   │   └── orders.py
│   ├── config.py         # Configuration
│   └── main.py           # FastAPI application
├── lambda_handler.py     # Lambda entry point
├── requirements.txt      # Dependencies
├── Dockerfile            # Lambda container
└── Dockerfile.local      # Local development
```

## 🚀 Features

### Order Management

- ✅ Create orders with multiple items
- ✅ List all orders with pagination
- ✅ Get order by ID
- ✅ Update order status
- ✅ Delete orders
- ✅ Get orders by user ID
- ✅ Automatic order total calculation

### Order Items

- ✅ Multiple items per order
- ✅ Product ID tracking
- ✅ Quantity management
- ✅ Price at order time

### Notification Integration

- ✅ SNS topic publishing
- ✅ Order created events
- ✅ Order status updates
- ✅ Asynchronous email delivery

### AWS Integration

- **RDS MySQL**: Order persistence
- **SNS**: Event publishing
- **SQS**: Message queuing
- **Lambda**: Serverless execution
- **Secrets Manager**: Credentials

## 📡 API Endpoints

### Base URL

```
https://{api-gateway-url}/orders
```

### Order Endpoints

#### Create Order

```http
POST /orders
Content-Type: application/json

{
  "user_id": 1,
  "status": "pending",
  "items": [
    {
      "product_id": 1,
      "quantity": 2,
      "price_at_order": 29.99
    },
    {
      "product_id": 2,
      "quantity": 1,
      "price_at_order": 49.99
    }
  ]
}
```

**Response**: `201 Created`

```json
{
  "order_id": 1,
  "user_id": 1,
  "status": "pending",
  "order_total": 109.97,
  "created_at": "2024-01-15T10:30:00",
  "items": [
    {
      "order_item_id": 1,
      "product_id": 1,
      "quantity": 2,
      "price_at_order": 29.99
    },
    {
      "order_item_id": 2,
      "product_id": 2,
      "quantity": 1,
      "price_at_order": 49.99
    }
  ]
}
```

**SNS Event Published**: Order created notification

#### List Orders

```http
GET /orders?page=1&page_size=10
```

**Response**: `200 OK`

```json
{
  "orders": [...],
  "total": 50,
  "page": 1,
  "page_size": 10
}
```

#### Get Order

```http
GET /orders/{order_id}
```

**Response**: `200 OK`

#### Update Order

```http
PUT /orders/{order_id}
Content-Type: application/json

{
  "status": "shipped"
}
```

**Response**: `200 OK`

**SNS Event Published**: Order status updated

#### Delete Order

```http
DELETE /orders/{order_id}
```

**Response**: `204 No Content`

#### Get User Orders

```http
GET /users/{user_id}/orders
```

**Response**: `200 OK`

```json
{
  "orders": [...],
  "total": 5
}
```

## 🗄️ Database Schema

```sql
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    order_total DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status)
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price_at_order DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id)
);
```

## 📬 SNS Integration

### Event Publishing

```python
# Publish order created event
sns_client.publish(
    TopicArn=SNS_TOPIC_ARN,
    Message=json.dumps({
        'event_type': 'order_created',
        'order_id': order.order_id,
        'user_id': order.user_id,
        'order_total': float(order.order_total),
        'timestamp': datetime.now().isoformat()
    }),
    Subject='Order Created'
)
```

### Event Types

| Event           | Trigger          | Notification             |
| --------------- | ---------------- | ------------------------ |
| `order_created` | New order        | Order confirmation email |
| `order_updated` | Status change    | Status update email      |
| `order_shipped` | Status = shipped | Shipping notification    |

## ⚙️ Configuration

### Environment Variables

| Variable        | Description         | Default     |
| --------------- | ------------------- | ----------- |
| `ENVIRONMENT`   | Environment name    | `dev`       |
| `LOG_LEVEL`     | Logging level       | `INFO`      |
| `AWS_REGION`    | AWS region          | `us-east-1` |
| `SNS_TOPIC_ARN` | SNS topic ARN       | -           |
| `DB_HOST`       | Database host (dev) | `localhost` |

### IAM Permissions

Required permissions:

- `sns:Publish` - Publish to SNS topic
- `secretsmanager:GetSecretValue` - Fetch DB credentials
- `rds:DescribeDBInstances` - RDS access
- `logs:CreateLogGroup` - CloudWatch logging

## 🚀 Local Development

### Using Docker Compose

```bash
# Start service
docker-compose up

# Create order
curl -X POST http://localhost:8000/orders \
  -H "Content-Type: application/json" \
  -d '{"user_id":1,"items":[{"product_id":1,"quantity":2,"price_at_order":29.99}]}'

# View logs
docker-compose logs -f

# Stop service
docker-compose down
```

## 📦 Deployment

```bash
# Build Docker image
docker build -t orders-service:latest .

# Tag for ECR
docker tag orders-service:latest {account}.dkr.ecr.{region}.amazonaws.com/orders:latest

# Push to ECR
docker push {account}.dkr.ecr.{region}.amazonaws.com/orders:latest

# Deploy with Terraform
cd ../../terraform
terraform apply -var-file=dev.tfvars
```

## 🔐 Security

- **VPC**: Private subnet deployment
- **Security Groups**: Restricted access
- **SNS**: Topic access policies
- **Secrets Manager**: Encrypted credentials
- **Input Validation**: Pydantic schemas

## 📊 Monitoring

### CloudWatch Metrics

- Lambda invocations
- SNS publish success/failure
- Order creation rate
- Error rate

### CloudWatch Logs

```
INFO: Creating order for user_id=1
INFO: Order total calculated: 109.97
INFO: Publishing SNS event: order_created
INFO: Order created successfully: order_id=1
```

## 🧪 Testing

```bash
# Run tests
pytest

# Test order creation
pytest tests/test_order_service.py::test_create_order

# Test SNS integration
pytest tests/test_sns_integration.py
```

## 🔧 Troubleshooting

### SNS Publishing Failed

- Check SNS topic ARN
- Verify IAM permissions
- Review topic access policy

### Order Total Incorrect

- Verify item prices
- Check calculation logic
- Review order items

## 📈 Performance

- **Cold Start**: ~1.5 seconds
- **Warm Response**: ~60ms
- **Order Creation**: ~100ms
- **SNS Publishing**: ~20ms

## 🔄 Future Enhancements

- [ ] Payment integration
- [ ] Order tracking
- [ ] Inventory reservation
- [ ] Order cancellation workflow
- [ ] Refund processing
- [ ] Order history export

## 📚 Related Documentation

- [Main Services README](../README.md)
- [Email Notifier Service](../email_notifier/README.md)
- [SNS/SQS Terraform Module](../../terraform/modules/sns_sqs/)

## 📄 License

Part of the Serverless E-Commerce Platform.
