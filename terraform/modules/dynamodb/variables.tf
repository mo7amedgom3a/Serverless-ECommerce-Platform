# Global Configuration
variable "global" {
  description = "Global configuration settings"
  type = object({
    aws_region  = string
    environment = string
  })
}

# DynamoDB Table Name
variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}
