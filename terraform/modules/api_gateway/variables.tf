variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "cors_allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "users_lambda_invoke_arn" {
  description = "Invoke ARN of the users Lambda function"
  type        = string
}

variable "users_lambda_function_name" {
  description = "Name of the users Lambda function"
  type        = string
}
