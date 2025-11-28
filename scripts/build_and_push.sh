#!/bin/bash
set -e

# Check if service name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <service_name>"
    echo "Example: $0 users"
    echo "This will build services/users_service and push to serverless-ecommerce-dev-users repo"
    exit 1
fi

SERVICE_SHORT_NAME=$1
SERVICE_DIR="services/${SERVICE_SHORT_NAME}_service"
REPO_NAME="serverless-ecommerce-dev-${SERVICE_SHORT_NAME}"
AWS_REGION=$(aws configure get region)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
FULL_IMAGE_URI="${ECR_URI}/${REPO_NAME}:latest"

# Check if service directory exists
if [ ! -d "$SERVICE_DIR" ]; then
    echo "Error: Directory $SERVICE_DIR does not exist."
    exit 1
fi

echo "----------------------------------------------------------------"
echo "Service: $SERVICE_SHORT_NAME"
echo "Directory: $SERVICE_DIR"
echo "Repository: $REPO_NAME"
echo "Image URI: $FULL_IMAGE_URI"
echo "----------------------------------------------------------------"

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}

# Build Docker image
echo "Building Docker image..."
# --provenance=false is CRITICAL for Lambda compatibility with newer Docker versions
docker build --platform linux/amd64 --provenance=false -t ${REPO_NAME} ${SERVICE_DIR}

# Tag image
echo "Tagging image..."
docker tag ${REPO_NAME}:latest ${FULL_IMAGE_URI}

# Push image
echo "Pushing image to ECR..."
docker push ${FULL_IMAGE_URI}

echo "Done! Image pushed to $FULL_IMAGE_URI"
