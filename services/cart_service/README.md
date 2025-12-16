# Cart Service

Shopping cart management service built with FastAPI and DynamoDB for serverless, scalable cart operations.

## 📋 Overview

The Cart Service manages user shopping carts with DynamoDB for fast, scalable NoSQL storage. It provides complete CRUD operations for cart items with automatic TTL-based expiration.

## 🏗️ Architecture

```
API Gateway → Lambda (FastAPI) → DynamoDB
```

### Technology Stack

- **Language**: Python 3.11
- **Framework**: FastAPI
- **Database**: AWS DynamoDB
- **Deployment**: AWS Lambda (Container)
- **API Adapter**: Mangum

## 📁 Project Structure

```
cart_service/
├── app/
│   ├── models/
│   │   └── cart_item.py      # CartItem model
│   ├── schemas/
│   │   └── cart.py            # Pydantic DTOs
│   ├── repositories/
│   │   └── cart_repository.py # DynamoDB operations
│   ├── services/
│   │   └── cart_service.py    # Business logic
│   ├── routers/
│   │   └── cart.py            # API routes
│   ├── config.py              # Configuration
│   └── main.py                # FastAPI app
├── lambda_handler.py          # Lambda entry point
├── requirements.txt
├── Dockerfile
└── Dockerfile.local
```

## 🚀 Features

### Cart Management

- ✅ Add items to cart
- ✅ Update item quantities
- ✅ Remove items
- ✅ Clear entire cart
- ✅ Get cart with totals
- ✅ Automatic TTL expiration (30 days)

### DynamoDB Integration

- ✅ Single-table design
- ✅ Global Secondary Index (GSI) on product_id
- ✅ Pay-per-request billing
- ✅ Point-in-time recovery
- ✅ Server-side encryption

### AWS Integration

- **DynamoDB**: Cart data storage
- **Lambda**: Serverless execution
- **CloudWatch**: Logging and monitoring

## 📡 API Endpoints

### Base URL

```
https://{api-gateway-url}/cart
```

### Get Cart

```http
GET /cart/{user_id}
```

**Response**: `200 OK`

```json
{
  "user_id": "user123",
  "items": [
    {
      "product_id": 1,
      "product_name": "Wireless Mouse",
      "quantity": 2,
      "price": 29.99,
      "subtotal": 59.98,
      "added_at": "2024-01-15T10:30:00Z"
    }
  ],
  "total_items": 2,
  "total_price": 59.98
}
```

### Add Item to Cart

```http
POST /cart/{user_id}/items
Content-Type: application/json

{
  "product_id": 1,
  "product_name": "Wireless Mouse",
  "quantity": 2,
  "price": 29.99
}
```

**Response**: `201 Created`

### Update Item Quantity

```http
PUT /cart/{user_id}/items/{product_id}
Content-Type: application/json

{
  "quantity": 3
}
```

**Response**: `200 OK`

### Remove Item

```http
DELETE /cart/{user_id}/items/{product_id}
```

**Response**: `204 No Content`

### Clear Cart

```http
DELETE /cart/{user_id}
```

**Response**: `204 No Content`

## 🗄️ DynamoDB Schema

### Table Design

**Table Name**: `{environment}-carts`

**Primary Key**:

- Partition Key: `user_id` (String)
- Sort Key: `item_id` (String) - Format: `ITEM#{product_id}`

**Attributes**:

- `user_id` - User identifier
- `item_id` - Item identifier
- `product_id` - Product ID (Number)
- `product_name` - Product name
- `quantity` - Quantity
- `price` - Price at add time
- `added_at` - Timestamp
- `ttl` - Expiration timestamp (30 days)

**Global Secondary Index**:

- Name: `ProductIndex`
- Partition Key: `product_id`
- Purpose: Query all carts containing a product

## ⚙️ Configuration

### Environment Variables

| Variable              | Description          | Default     |
| --------------------- | -------------------- | ----------- |
| `ENVIRONMENT`         | Environment name     | `dev`       |
| `LOG_LEVEL`           | Logging level        | `INFO`      |
| `AWS_REGION`          | AWS region           | `us-east-1` |
| `DYNAMODB_TABLE_NAME` | DynamoDB table name  | `dev-carts` |
| `CART_TTL_DAYS`       | Cart expiration days | `30`        |

## 🚀 Local Development

### Using Docker Compose

```bash
# Start service
docker-compose up

# Access API
curl http://localhost:8000/cart/user123

# View logs
docker-compose logs -f

# Stop service
docker-compose down
```

### Using Python Directly

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
export ENVIRONMENT=dev
export DYNAMODB_TABLE_NAME=dev-carts

# Run service
uvicorn app.main:app --reload --port 8000
```

## 📦 Deployment

### Build Docker Image

```bash
# Build for Lambda
docker build -t cart-service:latest .

# Tag for ECR
docker tag cart-service:latest {account}.dkr.ecr.{region}.amazonaws.com/cart:latest

# Push to ECR
docker push {account}.dkr.ecr.{region}.amazonaws.com/cart:latest
```

### Deploy with Terraform

```bash
cd ../../terraform

# Deploy DynamoDB + Lambda
terraform apply -var-file=dev.tfvars
```

## 🔐 Security

- **VPC**: Lambda in private subnets
- **DynamoDB**: Encryption at-rest and in-transit
- **IAM**: Least privilege access
- **TTL**: Automatic data cleanup

## 📊 Monitoring

### CloudWatch Metrics

- Lambda invocations, duration, errors
- DynamoDB read/write capacity
- Item count and table size

### CloudWatch Logs

```
INFO: Adding item to cart for user user123
INFO: Cart retrieved: 2 items, total: $59.98
INFO: Item removed from cart
```

## 🧪 Testing

```bash
# Run tests
pytest

# With coverage
pytest --cov=app

# Specific test
pytest tests/test_cart_service.py
```

## 📈 Performance

- **Response Time**: ~50ms (DynamoDB)
- **Throughput**: 1000+ req/s (on-demand)
- **TTL**: Automatic cleanup after 30 days
- **Scalability**: Auto-scaling with DynamoDB

## 🔄 Future Enhancements

- [ ] Cart sharing between users
- [ ] Saved for later functionality
- [ ] Cart merge on login
- [ ] Price change notifications
- [ ] Inventory validation
- [ ] Cart analytics

## 📚 Related Documentation

- [Main Services README](../README.md)
- [DynamoDB Module](../../terraform/modules/dynamodb/)
- [Cart Lambda Module](../../terraform/modules/lambdas/cart_lambda/)

## 📄 License

Part of the Serverless E-Commerce Platform.
