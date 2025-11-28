variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "ecr_image_uri" {
  description = "URI of the Docker image in ECR"
  type        = string
  
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets for Lambda VPC configuration"
  type        = list(string)
}

variable "lambda_sg_id" {
  description = "ID of the Lambda security group"
  type        = string
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Memory size for the Lambda function in MB"
  type        = number
  default     = 512
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "secrets_manager_secret_id" {
  description = "ID of the Secrets Manager secret for RDS credentials"
  type        = string
}

variable "secrets_manager_policy_arn" {
  description = "ARN of the Secrets Manager access policy"
  type        = string
}

variable "rds_policy_arn" {
  description = "ARN of the RDS access policy"
  type        = string
}

variable "vpc_policy_arn" {
  description = "ARN of the Lambda VPC execution policy"
  type        = string
}

variable "cloudwatch_policy_arn" {
  description = "ARN of the CloudWatch Logs policy"
  type        = string
}