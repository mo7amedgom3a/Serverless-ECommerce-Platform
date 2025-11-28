# Global Configuration
variable "global" {
  description = "Global configuration settings"
  type = object({
    aws_region  = string
    environment = string
  })
}

# RDS Configuration
variable "rds_config" {
  description = "RDS database configuration"
  type = object({
    db_name           = string
    db_username       = string
    db_password       = string
    db_port           = number
    allocated_storage = number
    instance_class    = string
    multi_az          = bool
    create_proxy      = bool
  })
  sensitive = true
}

# Module Dependencies (outputs from other modules)
variable "private_subnet_ids" {
  description = "IDs of the private subnets for RDS"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "ID of the security group for RDS"
  type        = string
}

variable "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret for RDS credentials"
  type        = string
  default     = ""
}
