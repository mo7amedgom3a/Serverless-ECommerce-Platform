# Global Configuration
variable "global" {
  description = "Global configuration settings"
  type = object({
    aws_region  = string
    environment = string
  })
}

# Lambda Configuration
variable "lambda_config" {
  description = "Lambda function configuration"
  type = object({
    orders_ecr_image_uri = string
    timeout              = number
    memory_size          = number
    env_vars             = map(string)
  })
}

# Module Dependencies
variable "private_subnet_ids" {
  description = "IDs of the private subnets for Lambda VPC configuration"
  type        = list(string)
}

variable "lambda_sg_id" {
  description = "ID of the Lambda security group"
  type        = string
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

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for order notifications"
  type        = string
  default     = ""
}

variable "sns_publish_policy_arn" {
  description = "ARN of the SNS publish policy"
  type        = string
  default     = null
}
