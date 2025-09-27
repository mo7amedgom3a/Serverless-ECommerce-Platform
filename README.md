# Serverless E-Commerce Platform on AWS

This project is a **learning-focused serverless e-commerce application** built on AWS.  
It demonstrates how to combine multiple AWS services to create a scalable, event-driven architecture for products, users, carts, orders, and image uploads.

---

## 🏗️ Architecture Overview

![Architecture Diagram](./architecture.png)

### Core AWS Services

- **CloudFront**  
  Global CDN in front of API Gateway and S3 to serve static and API content with low latency.

- **Route 53**  
  Custom domain for the API and static assets.

- **Cognito**  
  User pool for authentication and JWT token issuance. API Gateway uses a Cognito Authorizer to protect endpoints.

- **API Gateway (HTTP API)**  
  Entry point for all HTTP requests from clients. Routes requests to Lambda functions:
  - `api_users_lambda` for user actions
  - `api_products_lambda` for product management
  - `api_orders_lambda` for orders
  - `api_cart_lambda` for cart operations
  - `image_processing_lambda` for image processing
  

- **AWS Lambda (Docker container images)**  
  Stateless compute for each micro-service endpoint. Packaged as container images in ECR.

- **Amazon RDS (via RDS Proxy)**  
  Primary relational database for users, products, orders, order items, and shipments.

- **DynamoDB**  
  Fast, denormalized access for product catalog, carts, and event logs.

- **ElastiCache (Redis)**  
  Caching layer for hot queries (product listings, user sessions).

- **S3**  
  Storage for user and product images. Presigned URLs let clients upload directly to S3.

- **SNS & SQS**  
  Event-driven messaging:
  - S3 image uploads → SNS → SQS → image processing Lambda
  - Order checkout workflow pushes to fulfillment queues

- **Step Functions**  
  Orchestrates checkout and order fulfillment workflows.
  - `checkout_workflow` for checkout workflow

- **Secrets Manager**  
  Secure storage of DB credentials and API keys for Lambdas.

- **IAM Roles & Policies**  
  Least privilege for each Lambda and service.

- **CloudWatch**  
  Logs, metrics, and alarms for observability.

---

## 📂 Repository Structure
```
/services/
  users_service/          # FastAPI microservice for user-related APIs
  products_service/       # FastAPI microservice for product/catalog APIs
  cart_service/           # FastAPI microservice for cart APIs
  orders_service/         # FastAPI microservice for orders/checkout APIs
  image_processor/        # Lambda for S3 image processing pipeline

/terraform/               # IaC for all AWS resources and modules
  modules/
    api_gateway/ cognito/ dynamodb/ lambdas/ networking/
    rds/ s3/ sns_sqs/ step_functions/

/scripts/
  schema.sql              # Example RDS schema for relational entities

/github-actions/          # CI/CD workflows (lint, test, docker, terraform)
/ansible/                 # Optional host/bootstrap tasks
architecture.png          # System diagram
database_rds_schema.png   # Relational schema diagram
```

---

## 🧩 Service Architecture (FastAPI + Layered Pattern)

All business services are implemented with FastAPI and follow a layered architecture to keep concerns separated and testable:

- **API layer (`routers`/`controllers`)**: Defines HTTP routes and request/response schemas. Thin glue only.
- **Service layer (`services`)**: Business rules and workflows. Orchestrates repositories and external clients.
- **Repository layer (`repositories`)**: Data access for RDS, DynamoDB, and cache. No business logic.
- **Domain models (`models`)**: ORM models (RDS) and DynamoDB item mappers.
- **Schemas (`schemas`)**: Pydantic request/response contracts.
- **Infrastructure (`clients`, `config`, `dependencies`)**: AWS/Boto3 clients, connection pools, DI providers.

Recommended per-service layout:
```
services/<name>_service/app/
  main.py                 # FastAPI app factory + startup/shutdown hooks
  routers/                # HTTP endpoints (thin controllers)
  services/               # Business logic
  repositories/           # RDS/DynamoDB/Cache access
  models/                 # SQLAlchemy models
  schemas/                # Pydantic models
  clients/                # Boto3, Redis/ElastiCache, RDS proxy, etc.
  config.py               # Settings via env vars (12-factor)
  dependencies.py         # DI wiring, auth, pagination helpers
  __init__.py
```

Key dependencies (typical): FastAPI, Uvicorn, Pydantic, SQLAlchemy, Boto3/aioboto3, Redis client, and a DB driver (e.g., psycopg for PostgreSQL via RDS Proxy). Use async variants where practical.

---

## 🔐 Authentication & Authorization

- **Cognito** issues JWTs; API Gateway uses a Cognito Authorizer for protected routes.
- Services read user identity from the verified JWT (scopes/claims) injected by API Gateway.
- Favor resource‑level authorization in the Service layer and data‑level checks in Repositories where applicable.

---

## 🔗 API Gateway Routing (REST)

API Gateway (HTTP API) forwards to Lambda integrations. Suggested versioned base path: `/v1`.

- `products/{proxy+}` → `api_products_lambda`
- `users/{proxy+}` → `api_users_lambda`
- `orders/{proxy+}` → `api_orders_lambda`
- `cart/{proxy+}` → `api_cart_lambda`
- `image-processing` events are asynchronous via S3/SNS/SQS → `image_processing_lambda`

API conventions:
- **Content type**: `application/json; charset=utf-8`
- **Pagination**: cursor or offset style. Example: `?cursor=abc123&limit=20` or `?page=1&page_size=20`
- **Idempotency**: send `Idempotency-Key` for POST that can be retried
- **Errors (standard shape)**:
```json
{ "error": { "code": "RESOURCE_NOT_FOUND", "message": "...", "request_id": "..." } }
```

---

## 🗃️ Data Layer

- **RDS via RDS Proxy**: source of truth for users, products, orders, order_items, shipments. Use SQLAlchemy for ORM and connection pooling through the proxy.
- **DynamoDB**: denormalized projections for product catalog, carts, and audit/event logs. Streamlined access paths and GSIs for hot queries.
- **ElastiCache (Redis)**: cache hot reads (e.g., product list). Choose explicit TTLs and cache‑key namespaces per service.

### Relational Database (RDS)

This is our source of truth for core business entities with complex relationships.

![RDS Schema Diagram](./database_rds_schema.png)

| Table | Primary Key | Purpose | Key Relationships |
|-------|------------|---------|-------------------|
| `users` | `user_id` | Customer accounts | One-to-many with orders |
| `products` | `product_id` | Core product data | One-to-one with inventory, one-to-many with order_items |
| `product_inventory` | `inventory_id` | Stock levels | One-to-one with products |
| `orders` | `order_id` | Customer orders | Many-to-one with users, one-to-many with order_items |
| `order_items` | `order_item_id` | Line items in orders | Many-to-one with orders and products |
| `shipments` | `shipment_id` | Delivery tracking | Many-to-one with orders |

```sql
-- Sample schema (simplified from scripts/schema.sql)
CREATE TABLE users (
    user_id         BIGSERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    email           VARCHAR(255) NOT NULL UNIQUE,
    hashed_password TEXT NOT NULL,
    address         TEXT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id      BIGSERIAL PRIMARY KEY,
    sku             VARCHAR(100) NOT NULL UNIQUE,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    price           DECIMAL(10,2) NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- See scripts/schema.sql for complete schema
```

### Non-Relational Database (DynamoDB)

This is where we keep "quick read" data or data that doesn't fit relational constraints well.

| Table | Partition Key / Sort Key | Purpose | Example Attributes |
|-------|-------------------------|---------|-------------------|
| `ProductCatalog` | PK = `product_id` | Denormalized product info for super-fast browsing | name, price, image_urls, thumbnail_url, category, tags |
| `UserCart` | PK = `user_id` | Current shopping cart state per user | items: [{product_id, quantity}], last_updated |
| `ProductImagesMeta` | PK = `image_id` | Metadata for uploaded images | product_id, status (original/thumbnail), s3_url |
| `OrderEvents` (optional) | PK = `order_id`, SK = `timestamp` | Event sourcing / audit trail for orders | event_type, payload |

Repository pattern:
```python
class ProductRepository:
    def __init__(self, session_factory, ddb_table, cache):
        self._session_factory = session_factory
        self._ddb_table = ddb_table
        self._cache = cache

    def get_by_id(self, product_id: str):
        cache_key = f"product:{product_id}"
        if cached := self._cache.get(cache_key):
            return cached
        with self._session_factory() as session:
            product = session.get(ProductORM, product_id)
        if product:
            self._cache.set(cache_key, product, ex=300)
        return product
```

---

## 🖼️ Image Processing Pipeline

1. Client uploads to S3 via presigned URL.
2. S3 event → SNS topic → SQS queue.
3. `image_processing_lambda` reads SQS, transforms assets (resize, optimize), stores processed objects, and updates image URLs in DynamoDB and RDS.

Message example:
```json
{
  "bucket": "images-upload",
  "key": "raw/12345.png",
  "entityType": "product",
  "entityId": "prod_123",
  "correlationId": "a1b2c3"
}
```

---

## 🧪 Testing Strategy

- Unit tests for Services and Repositories with mocks/fakes.
- Contract tests for routers using FastAPI TestClient.
- Integration tests with local DB/Dynamo (e.g., docker-compose or LocalStack) and ephemeral resources.
- Load tests (k6 or Locust) for hot APIs.

Run locally (example):
```
pytest -q
```

---

## 🛠️ Local Development

Requirements: Python 3.11+, Docker, AWS CLI.

Example workflow for a service (e.g., `products_service`):
```
cd services/products_service
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8001
```

Environment variables (sample `.env`):
```
AWS_REGION=us-east-1
DB_URL=postgresql+psycopg://user:pass@rds-proxy:5432/app
DDB_TABLE_PRODUCTS=products
DDB_TABLE_CARTS=carts
REDIS_URL=redis://localhost:6379/0
S3_BUCKET_IMAGES=images-upload
SNS_TOPIC_IMAGE_UPLOADS=arn:aws:sns:us-east-1:123456789012:image-uploads
SQS_QUEUE_IMAGE_PROCESSING=arn:aws:sqs:us-east-1:123456789012:image-processing
LOG_LEVEL=INFO
```

Optional: run AWS services locally with LocalStack for integration tests.

---

## 🚀 Deploy with Terraform

Prerequisites: Terraform 1.5+, AWS CLI with credentials, and an S3 bucket for remote state (recommended).

```
cd terraform
terraform init
terraform workspace new dev || terraform workspace select dev
terraform plan -var-file=dev.tfvars
terraform apply -auto-approve -var-file=dev.tfvars
```

Outputs include API endpoint, Cognito pool IDs, ARNs for SNS/SQS, and resource names. Repeat with `staging.tfvars` / `prod.tfvars` for other environments.


## 🛡️ Security

- IAM roles per Lambda with least privilege.
- Secrets in AWS Secrets Manager; never commit secrets.
- Parameter validation at the API boundary (Pydantic) and authorization checks in Services.
- RDS via RDS Proxy for connection pooling and IAM auth readiness.

---

## 🤝 Contributing

1. Create a feature branch.
2. Add/adjust tests.
3. Run formatters/linters/tests locally.
4. Open a PR. CI will run unit tests, build service containers, and validate Terraform.

---

## 🗺️ Roadmap (high level)

- Add example FastAPI service skeletons in `services/*/app`.
- Implement repository adapters for RDS/DynamoDB and cache layer with Redis.
- Add Step Functions definition for `checkout_workflow` and sample saga steps.

## 📚 Learning Resources
- [AWS Lambda with FastAPI](https://docs.aws.amazon.com/lambda/latest/dg/python-handler-fastapi.html)
- [AWS Lambda with Python](https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html)
- [AWS Lambda with Docker](https://docs.aws.amazon.com/lambda/latest/dg/python-handler-docker.html)
- [AWS Lambda with Terraform](https://docs.aws.amazon.com/lambda/latest/dg/terraform-build.html)
- [AWS Lambda with FastAPI and Terraform](https://docs.aws.amazon.com/lambda/latest/dg/terraform-build.html)
- [AWS API Gateway with FastAPI](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-fastapi.html)
- [AWS API Gateway with Python](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-python.html)
- [AWS API Gateway with Docker](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-docker.html)
- [AWS API Gateway with Terraform](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-terraform.html)
- [AWS API Gateway with FastAPI and Terraform](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-fastapi-terraform.html)

## 📝 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

