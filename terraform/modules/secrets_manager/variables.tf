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
    db_name     = string
    db_username = string
    db_password = string
    db_port     = any
  })
  sensitive = true
}

# Runtime RDS values (outputs from RDS module)
variable "rds_address" {
  description = "Address of the RDS instance"
  type        = string
}

variable "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  type        = string
}

variable "rds_proxy_endpoint" {
  description = "RDS Proxy endpoint"
  type        = string
  default     = ""
}
