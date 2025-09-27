variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "secrets_arns" {
  description = "ARNs of the Secrets Manager secrets"
  type        = list(string)
}

variable "rds_resource_arns" {
  description = "ARNs of the RDS resources"
  type        = list(string)
  default     = ["*"]
}
