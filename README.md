# Serverless E-Commerce Platform on AWS

A **production-ready serverless e-commerce application** built on AWS, demonstrating modern cloud-native architecture with microservices, event-driven workflows, and infrastructure as code.

> 🎯 **Learning Project**: This platform showcases best practices for building scalable, serverless applications using AWS services, Terraform, and modern development patterns.

---

## 🏗️ Architecture Overview

![Architecture Diagram](./architecture.png)

This platform implements a complete e-commerce system using AWS serverless services, featuring:

- **Microservices Architecture** - Independent services for users, products, orders, cart, and workflows
- **Event-Driven Design** - Asynchronous processing with SNS/SQS and Step Functions
- **Multi-Language Support** - Python (FastAPI) and Go Lambda functions
- **Infrastructure as Code** - Complete Terraform modules for all AWS resources
- **API-First Design** - RESTful APIs with API Gateway integration

---

## 🎬 Step Functions Orchestration

The platform uses AWS Step Functions to orchestrate complex order workflows with payment processing, inventory management, and shipment creation.

### Workflow Visualization

![Step Functions Workflow](/stepfunctions_graph.svg)

### Workflow Demo

Click on this link to watch the Step Functions orchestration in action: [Step Functions Workflow](https://drive.google.com/file/d/15ILIvdd3vSPrZKpo9reUrFXwWOCY6Ivc/view?usp=sharing)


**Workflow Steps:**
1. **Wait** - 3-second delay before processing
2. **Process Payment** - Validate and process payment
3. **Payment Decision** - Route based on payment status
4. **Check Inventory** - Verify product availability
5. **Inventory Decision** - Route based on stock status
6. **Create Shipment** - Generate tracking and shipment details

**API Integration:**
```bash
# Start workflow via API Gateway
curl -X POST https://YOUR_API.execute-api.us-east-1.amazonaws.com/prod/workflow/start \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "ORDER-12345",
    "productId": "PROD-001",
    "quantity": 2,
    "amount": 99.99,
    "paymentMethod": "credit_card"
  }'
```

See [API_GATEWAY_TESTING.md](./API_GATEWAY_TESTING.md) for complete testing guide.

---

## 🧩 Core AWS Services

### Compute & API Layer
- **API Gateway** - RESTful HTTP API with Lambda proxy integration and Step Functions direct integration
- **AWS Lambda** - Containerized microservices (Python FastAPI + Go)
- **ECR** - Container image registry for Lambda functions

### Data Layer
- **Amazon RDS** (MySQL via RDS Proxy) - Relational data for users, products, orders
- **DynamoDB** - NoSQL for carts, product catalog, and event logs
- **ElastiCache (Redis)** - Caching layer for hot queries

### Storage & CDN
- **S3** - Image storage with presigned URLs
- **CloudFront** - Global CDN for API and static assets

### Orchestration & Messaging
- **Step Functions** - Workflow orchestration for order processing
- **SNS & SQS** - Event-driven messaging for image processing and notifications
- **EventBridge** - Event routing (future enhancement)

### Security & Observability
- **Cognito** - User authentication and JWT tokens
- **Secrets Manager** - Secure credential storage
- **IAM** - Fine-grained access control
- **CloudWatch** - Logs, metrics, and alarms

---

## 📂 Repository Structure

```
├── services/                    # Microservices
│   ├── users_service/          # Go - User management
│   ├── products_service/       # Go - Product catalog with Redis caching
│   ├── orders_service/         # Go - Order processing
│   ├── cart_service/           # Python FastAPI - Shopping cart
│   ├── payment_service/        # Go - Payment processing (Step Functions)
│   ├── inventory_service/      # Go - Inventory management (Step Functions)
│   ├── shipment_service/       # Go - Shipment creation (Step Functions)
│   ├── email_notifier/         # Python - Email notifications
│   └── image_processor/        # Python - S3 image processing
│
├── terraform/                   # Infrastructure as Code
│   ├── main.tf                 # Root module
│   ├── variables.tf            # Global variables
│   ├── outputs.tf              # Stack outputs
│   └── modules/
│       ├── api_gateway/        # API Gateway + Step Functions integration
│       ├── lambdas/            # Lambda function modules
│       ├── step_functions/     # State machine definitions
│       ├── dynamodb/           # DynamoDB tables
│       ├── rds/                # RDS + RDS Proxy
│       ├── elasticache/        # Redis cluster
│       ├── networking/         # VPC, subnets, security groups
│       ├── iam/                # IAM roles and policies
│       ├── s3/                 # S3 buckets
│       ├── sns_sqs/            # Messaging infrastructure
│       ├── secrets_manager/    # Secrets storage
│       └── cognito/            # User authentication
│
├── scripts/
│   └── schema.sql              # RDS database schema
│
├── docs/
│   ├── API_GATEWAY_TESTING.md  # API testing guide
│   └── STEP_FUNCTIONS_TESTING.md # Workflow testing guide
│
├── architecture.png            # System architecture diagram
├── database_rds_schema.png     # Database schema
├── step-function.png           # Step Functions workflow
└── step-function-demo.mp4      # Workflow demonstration video
```

---

## 🎯 Service Architecture

### Go Services (Layered Architecture)

All Go services follow a clean architecture pattern:

```
services/<service_name>/
├── cmd/
│   └── lambda/
│       └── main.go            # Lambda entry point
├── internal/
│   ├── handler/               # Business logic
│   ├── service/               # Domain services
│   ├── repository/            # Data access layer
│   ├── models/                # Domain models
│   ├── dto/                   # Data transfer objects
│   ├── config/                # Configuration
│   ├── database/              # DB connection
│   ├── cache/                 # Redis client
│   ├── router/                # HTTP routing
│   └── middleware/            # Logging, error handling
├── go.mod
├── go.sum
└── Dockerfile                 # Multi-stage build
```

**Key Features:**
- **Dependency Injection** - Clean separation of concerns
- **Repository Pattern** - Abstracted data access
- **Middleware** - Centralized logging and error handling
- **Configuration** - Environment-based settings
- **Testing** - Unit and integration test support

### Python Services (FastAPI)

Python services use FastAPI with a layered approach:

```
services/<service_name>/app/
├── main.py                    # FastAPI application
├── routers/                   # HTTP endpoints
├── services/                  # Business logic
├── repositories/              # Data access
├── models/                    # SQLAlchemy/Pydantic models
├── schemas/                   # Request/response schemas
├── clients/                   # AWS SDK clients
├── config.py                  # Settings
└── dependencies.py            # Dependency injection
```

---

## 🔐 Authentication & Authorization

- **Cognito User Pool** - Manages user registration and authentication
- **JWT Tokens** - Issued by Cognito for API access
- **API Gateway Authorizer** - Validates JWT tokens
- **IAM Roles** - Service-to-service authentication

**Authentication Flow:**
1. User signs up/signs in via Cognito
2. Cognito issues JWT access token
3. Client includes token in `Authorization` header
4. API Gateway validates token before routing to Lambda
5. Lambda receives verified user identity from API Gateway

---

## 🗃️ Data Architecture

### Relational Database (RDS MySQL)

Source of truth for core business entities:

![RDS Schema](./database_rds_schema.png)

| Table | Purpose | Key Relationships |
|-------|---------|-------------------|
| `users` | Customer accounts | → orders |
| `products` | Product catalog | → inventory, order_items |
| `product_inventory` | Stock levels | ← products |
| `orders` | Customer orders | ← users, → order_items, shipments |
| `order_items` | Order line items | ← orders, products |
| `shipments` | Delivery tracking | ← orders |

**Connection Pooling:** RDS Proxy manages connections efficiently for Lambda functions.

### NoSQL Database (DynamoDB)

Fast access for denormalized data:

| Table | Partition Key | Purpose |
|-------|--------------|---------|
| `ProductCatalog` | `product_id` | Quick product lookups |
| `UserCart` | `user_id` | Shopping cart state |
| `ProductImagesMeta` | `image_id` | Image metadata |
| `OrderEvents` | `order_id` | Event sourcing/audit |

### Caching Layer (Redis)

- Product listings cache (5-minute TTL)
- User session data
- Hot query results

---

## 🖼️ Image Processing Pipeline

Asynchronous image processing workflow:

```
Client → S3 (presigned URL) → S3 Event → SNS → SQS → Lambda
                                                        ↓
                                                  Process Image
                                                        ↓
                                            S3 (thumbnails) + DynamoDB
```

**Features:**
- Presigned URLs for direct client uploads
- Automatic thumbnail generation
- Image optimization and compression
- Metadata storage in DynamoDB

---

## 🚀 Deployment

### Prerequisites

- **Terraform** 1.5+
- **AWS CLI** configured with credentials
- **Docker** for building container images
- **Go** 1.21+ (for local development)
- **Python** 3.11+ (for local development)

### Step 1: Build and Push Container Images

```bash
# Authenticate with ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# Build and push each service
cd services/payment_service
docker build -t payment-service .
docker tag payment-service:latest \
  <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/serverless-ecommerce-dev-payment:latest
docker push \
  <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/serverless-ecommerce-dev-payment:latest

# Repeat for all services...
```

### Step 2: Deploy Infrastructure

```bash
cd terraform

# Initialize Terraform
terraform init

# Select/create workspace
terraform workspace new dev || terraform workspace select dev

# Plan deployment
terraform plan -var-file=dev.tfvars

# Apply changes
terraform apply -var-file=dev.tfvars
```

### Step 3: Get Outputs

```bash
# API Gateway URL
terraform output api_gateway_url

# Step Functions workflow URL
terraform output workflow_api_url

# Cognito User Pool ID
terraform output cognito_user_pool_id
```

---

## 🧪 Testing

### Unit Tests

```bash
# Go services
cd services/products_service
go test ./...

# Python services
cd services/cart_service
pytest
```

### Integration Tests

```bash
# Test API Gateway endpoint
curl -X POST $(terraform output -raw workflow_api_url) \
  -H "Content-Type: application/json" \
  -d @test-data/order-success.json

# Monitor execution
aws stepfunctions describe-execution \
  --execution-arn <ARN_FROM_RESPONSE>
```

### Load Testing

```bash
# Using k6
k6 run scripts/load-test.js
```

---

## 📊 Monitoring & Observability

### CloudWatch Dashboards

- API Gateway metrics (requests, latency, errors)
- Lambda metrics (invocations, duration, errors)
- Step Functions execution metrics
- RDS performance metrics
- DynamoDB capacity metrics

### CloudWatch Logs

- `/aws/lambda/<function-name>` - Lambda execution logs
- `/aws/stepfunctions/<state-machine>` - Workflow execution logs
- `/aws/apigateway/<api-id>` - API Gateway access logs

### Alarms

- Lambda error rate > 5%
- API Gateway 5xx errors
- RDS CPU > 80%
- DynamoDB throttling events

---

## 🛡️ Security Best Practices

✅ **Implemented:**
- IAM roles with least privilege
- Secrets in AWS Secrets Manager
- VPC isolation for Lambda functions
- Security groups for RDS and ElastiCache
- Encryption at rest (S3, RDS, DynamoDB)
- Encryption in transit (TLS/HTTPS)
- API Gateway request validation
- Cognito user authentication

🔜 **Recommended for Production:**
- WAF rules for API Gateway
- GuardDuty for threat detection
- AWS Config for compliance
- CloudTrail for audit logging
- Backup and disaster recovery plan
- Multi-region deployment

---

## 🗺️ Roadmap

- [x] Core microservices (users, products, orders, cart)
- [x] Step Functions workflow orchestration
- [x] API Gateway integration
- [x] Image processing pipeline
- [x] Email notifications
- [ ] Payment gateway integration (Stripe/PayPal)
- [ ] Real-time inventory updates (WebSocket)
- [ ] Product recommendations (ML)
- [ ] Multi-region deployment
- [ ] GraphQL API layer
- [ ] Mobile app (React Native)

---

## 📚 Documentation

- [API Gateway Testing Guide](./API_GATEWAY_TESTING.md)
- [Step Functions Testing Guide](./STEP_FUNCTIONS_TESTING.md)
- [Database Schema](./scripts/schema.sql)
- [Architecture Decisions](./docs/ADR.md)

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- AWS Serverless Application Model (SAM) team
- Terraform AWS Provider maintainers
- FastAPI and Go Lambda runtime communities
- All contributors and learners using this project

---

## 📧 Contact

For questions or feedback, please open an issue on GitHub.

**Built with ❤️ for learning serverless architecture on AWS**
