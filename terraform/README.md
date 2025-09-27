# Terraform Infrastructure for Serverless E-Commerce Platform

This directory contains Terraform configurations for deploying the infrastructure of the Serverless E-Commerce Platform on AWS.

## Infrastructure Components

- **VPC** with public and private subnets
- **NAT Gateway** for private subnet internet access
- **EC2 Instance** for RDS administration
- **Security Groups** for EC2-RDS and Lambda-RDS connections
- **Lambda Function** for the users service
- **API Gateway** with proxy integration to the Lambda function

## Module Structure

- `modules/networking`: VPC, subnets, NAT Gateway, EC2 instance, security groups
- `modules/lambdas`: Lambda function for users service
- `modules/api_gateway`: API Gateway with routes to Lambda functions

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform 1.5+ installed
- Docker image for the users service pushed to ECR

## Usage

### Initialize Terraform

```bash
terraform init
```

### Create a Workspace (optional)

```bash
terraform workspace new dev
```

### Plan the Deployment

```bash
terraform plan -var-file=dev.tfvars
```

### Apply the Configuration

```bash
terraform apply -var-file=dev.tfvars
```

### Destroy the Infrastructure

```bash
terraform destroy -var-file=dev.tfvars
```

## Variables

Edit the `dev.tfvars` file to customize the deployment:

- `aws_region`: AWS region to deploy resources
- `environment`: Environment name (e.g., dev, staging, prod)
- `vpc_cidr`: CIDR block for the VPC
- `public_subnet_cidrs`: CIDR blocks for the public subnets
- `private_subnet_cidrs`: CIDR blocks for the private subnets
- `availability_zones`: Availability zones for the subnets
- `ec2_ami_id`: AMI ID for the EC2 instance
- `ec2_instance_type`: Instance type for the EC2 instance
- `ec2_key_name`: Key pair name for the EC2 instance
- `users_ecr_image_uri`: URI of the Docker image in ECR for users service
- `lambda_timeout`: Timeout for the Lambda function in seconds
- `lambda_memory_size`: Memory size for the Lambda function in MB
- `users_lambda_env_vars`: Environment variables for the users Lambda function
- `secrets_manager_arn`: ARN of the Secrets Manager secret for the Lambda function
- `cors_allowed_origins`: List of allowed origins for CORS

## Outputs

After applying the configuration, Terraform will output:

- VPC ID
- Public and private subnet IDs
- EC2 instance public IP
- Lambda function name and ARN
- API Gateway endpoint URL
- API Gateway invoke URL
- Users API URL

## State Management

By default, the state is stored locally. For production use, it's recommended to configure a remote backend (e.g., S3 with DynamoDB for state locking). Uncomment and configure the backend section in `main.tf`.
