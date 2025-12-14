# Global Configuration
variable "global" {
  description = "Global configuration settings"
  type = object({
    aws_region  = string
    environment = string
  })
}

# Redis Configuration
variable "redis_config" {
  description = "Redis cluster configuration"
  type = object({
    node_type        = string
    num_cache_nodes  = number
    engine_version   = string
    parameter_family = string
  })
}

# Module Dependencies
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets for Redis"
  type        = list(string)
}

variable "lambda_sg_id" {
  description = "ID of the Lambda security group for Redis access"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for notifications (optional)"
  type        = string
  default     = ""
}
