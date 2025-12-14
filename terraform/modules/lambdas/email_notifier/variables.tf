variable "global" {
  description = "Global configuration settings"
  type = object({
    aws_region  = string
    environment = string
  })
}

variable "lambda_config" {
  description = "Lambda function configuration"
  type = object({
    email_notifier_ecr_image_uri = string
    timeout                      = number
    memory_size                  = number
    env_vars                     = map(string)
  })
}

variable "notification_config" {
  description = "Notification configuration"
  type = object({
    ses_sender_email = string
  })
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue to trigger Lambda"
  type        = string
}

variable "sqs_consume_policy_arn" {
  description = "ARN of the SQS consume policy"
  type        = string
}

variable "ses_send_email_policy_arn" {
  description = "ARN of the SES send email policy"
  type        = string
}

variable "cloudwatch_policy_arn" {
  description = "ARN of the CloudWatch Logs policy"
  type        = string
}
