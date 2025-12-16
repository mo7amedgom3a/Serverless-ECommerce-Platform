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
    cart_ecr_image_uri = string
    timeout            = number
    memory_size        = number
    env_vars           = map(string)
  })
}

# DynamoDB Table Name
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

# IAM Policy ARNs
variable "dynamodb_policy_arn" {
  description = "ARN of the DynamoDB access policy"
  type        = string
}

variable "cloudwatch_policy_arn" {
  description = "ARN of the CloudWatch Logs policy"
  type        = string
}
