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

variable "private_subnet_ids" {
  description = "IDs of the private subnets for RDS"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "ID of the security group for RDS"
  type        = string
}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
  default     = "ecommerce"
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
  default     = ""
}

variable "db_port" {
  description = "Port for the RDS database"
  type        = number
  default     = 3306
}

variable "allocated_storage" {
  description = "Allocated storage for the RDS instance in GB"
  type        = number
  default     = 20
}

variable "instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "create_proxy" {
  description = "Whether to create an RDS Proxy"
  type        = bool
  default     = false
}
