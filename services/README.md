# Serverless E-Commerce Platform - Services

This directory contains all microservices for the serverless e-commerce platform. Each service is independently deployable as an AWS Lambda function and follows a layered architecture pattern.

## 📋 Services Overview

| Service              | Language | Framework | Purpose                          | AWS Integration                |
| -------------------- | -------- | --------- | -------------------------------- | ------------------------------ |
| **Users Service**    | Python   | FastAPI   | User management & authentication | Lambda, RDS, Secrets Manager   |
| **Products Service** | Go       | Gin       | Product catalog & inventory      | Lambda, RDS, ElastiCache Redis |
| **Orders Service**   | Python   | FastAPI   | Order management & processing    | Lambda, RDS, SNS               |
| **Email Notifier**   | Python   | -         | Email notifications              | Lambda, SQS, SES               |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      API Gateway                             │
│         /users/*  |  /products/*  |  /orders/*              │
└──────┬──────────────┬────────────────┬────────────────────┘
       │              │                │
       ▼              ▼                ▼
┌────────────┐ ┌────────────┐  ┌────────────┐
│   Users    │ │  Products  │  │   Orders   │
│   Lambda   │ │   Lambda   │  │   Lambda   │
│  (Python)  │ │    (Go)    │  │  (Python)  │
└─────┬──────┘ └─────┬──────┘  └─────┬──────┘
      │              │                │
      │              │                ├──────► SNS Topic
      │              ▼                │           │
      │        ┌────────────┐         │           │
      │        │   Redis    │         │           ▼
      │        │   Cache    │         │      ┌──────────┐
      │        └────────────┘         │      │   SQS    │
      │                               │      │  Queue   │
      └───────────────┬───────────────┘      └────┬─────┘
                      │                           │
                      ▼                           ▼
               ┌────────────┐            ┌──────────────┐
               │    RDS     │            │    Email     │
               │   MySQL    │            │   Notifier   │
               └────────────┘            │   Lambda     │
                                         └──────┬───────┘
                                                │
                                                ▼
                                           ┌────────┐
                                           │  SES   │
                                           └────────┘
```

## 🚀 Quick Start

### Prerequisites

- Docker
- AWS CLI configured
- Terraform (for infrastructure)

### Local Development

Each service can be run locally using Docker:

```bash
# Users Service
cd users_service
docker-compose up

# Products Service
cd products_service
docker-compose up

# Orders Service
cd orders_service
docker-compose up
```

### Deployment

All services are deployed via Terraform:

```bash
cd ../terraform
terraform init
terraform apply -var-file=dev.tfvars
```

## 📚 Service Details

### [Users Service](./users_service/README.md)

- **Technology**: Python 3.11 + FastAPI
- **Purpose**: User registration, authentication, profile management
- **Database**: RDS MySQL
- **Key Features**:
  - User CRUD operations
  - Email validation
  - Secrets Manager integration

### [Products Service](./products_service/README.md)

- **Technology**: Go 1.21 + Gin
- **Purpose**: Product catalog and inventory management
- **Database**: RDS MySQL + ElastiCache Redis
- **Key Features**:
  - Product CRUD operations
  - Inventory management
  - Redis caching with Lazy Loading
  - 85-90% performance improvement

### [Orders Service](./orders_service/README.md)

- **Technology**: Python 3.11 + FastAPI
- **Purpose**: Order creation and management
- **Database**: RDS MySQL
- **Key Features**:
  - Order CRUD operations
  - Order items management
  - SNS notifications on order events
  - User-specific order retrieval

### [Email Notifier](./email_notifier/README.md)

- **Technology**: Python 3.11
- **Purpose**: Asynchronous email notifications
- **Integration**: SQS → Lambda → SES
- **Key Features**:
  - SQS event-driven processing
  - Email template rendering
  - SES email delivery
  - Dead letter queue for failures

## 🔧 Common Patterns

### Layered Architecture

All services follow a consistent layered architecture:

```
├── models/          # Database models (ORM)
├── schemas/dto/     # Request/Response DTOs
├── repositories/    # Data access layer
├── services/        # Business logic
├── routers/handlers/# HTTP handlers
└── main.py/main.go  # Application entry point
```

### Environment Configuration

Services use environment-aware configuration:

- **Development**: Environment variables from `.env`
- **Production**: AWS Secrets Manager for sensitive data

### Database Access

- **Connection Pooling**: Configured for optimal performance
- **Secrets Manager**: Database credentials stored securely
- **Migrations**: Schema managed via SQL scripts

## 📊 API Endpoints Summary

### Users Service

- `POST /users` - Create user
- `GET /users` - List users
- `GET /users/{id}` - Get user
- `PUT /users/{id}` - Update user
- `DELETE /users/{id}` - Delete user

### Products Service

- `POST /products` - Create product
- `GET /products` - List products (cached)
- `GET /products/{id}` - Get product (cached)
- `PUT /products/{id}` - Update product
- `DELETE /products/{id}` - Delete product
- `GET /products/{id}/inventory` - Get inventory
- `PUT /products/{id}/inventory` - Update inventory

### Orders Service

- `POST /orders` - Create order
- `GET /orders` - List all orders
- `GET /orders/{id}` - Get order
- `PUT /orders/{id}` - Update order
- `DELETE /orders/{id}` - Delete order
- `GET /users/{user_id}/orders` - Get user orders

## 🔐 Security

- **VPC**: All services run in private subnets
- **Security Groups**: Least privilege access
- **Secrets Manager**: Credentials rotation
- **IAM Roles**: Service-specific permissions
- **Encryption**: At-rest and in-transit

## 📈 Performance

### Products Service (with Redis)

- **Response Time**: 85-90% faster
- **Database Load**: 80%+ reduction
- **Cache Hit Rate**: >80% target
- **Throughput**: 8x increase

### All Services

- **Cold Start**: <2 seconds
- **Warm Response**: <100ms (without cache)
- **Concurrent Executions**: Auto-scaling

## 🧪 Testing

Each service includes:

- Unit tests for business logic
- Integration tests for database
- API endpoint tests

```bash
# Python services
pytest

# Go services
go test ./...
```

## 📝 Logging

All services use structured logging:

- **CloudWatch Logs**: Centralized logging
- **Log Levels**: INFO, DEBUG, ERROR
- **Request Tracing**: Request ID tracking

## 🔄 CI/CD

Services are deployed using:

1. **Build**: Docker images
2. **Push**: AWS ECR
3. **Deploy**: Terraform updates Lambda

## 📖 Additional Resources

- [Terraform Infrastructure](../terraform/README.md)
- [Database Schema](../scripts/schema.sql)
- [API Gateway Configuration](../terraform/modules/api_gateway/)

## 🤝 Contributing

1. Follow the layered architecture pattern
2. Add tests for new features
3. Update documentation
4. Use consistent naming conventions

## 📄 License

This project is part of the Serverless E-Commerce Platform.
