variable "global" {
  description = "Global configuration"
  type = object({
    environment = string
    aws_region  = string
  })
}

variable "lambda_config" {
  description = "Lambda configuration"
  type = object({
    shipment_ecr_image_uri = string
    timeout                = number
    memory_size            = number
    env_vars               = map(string)
  })
}

variable "cloudwatch_policy_arn" {
  description = "ARN of the CloudWatch Logs policy"
  type        = string
}
