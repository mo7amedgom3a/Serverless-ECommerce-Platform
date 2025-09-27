variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "rds_username" {
  description = "Username for the RDS database"
  type        = string
}

variable "rds_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}

variable "rds_address" {
  description = "Address of the RDS instance"
  type        = string
}

variable "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  type        = string
}

variable "rds_port" {
  description = "Port of the RDS instance"
  type        = any
}

variable "rds_name" {
  description = "Name of the RDS database"
  type        = string
}

variable "rds_proxy_endpoint" {
  description = "RDS Proxy endpoint"
  type        = string
  default     = ""
}