# Global Configuration
variable "global" {
  description = "Global configuration settings"
  type = object({
    aws_region  = string
    environment = string
  })
}

# Module Dependencies
variable "secrets_arns" {
  description = "ARNs of the Secrets Manager secrets"
  type        = list(string)
}

variable "rds_resource_arns" {
  description = "ARNs of the RDS resources"
  type        = list(string)
  default     = ["*"]
}
