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

variable "sns_topic_arns" {
  description = "ARNs of the SNS topics"
  type        = list(string)
  default     = []
}

variable "sqs_queue_arns" {
  description = "ARNs of the SQS queues"
  type        = list(string)
  default     = []
}

variable "enable_ses_policy" {
  description = "Enable SES send email policy"
  type        = bool
  default     = false
}
