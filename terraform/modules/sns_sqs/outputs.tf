output "sns_topic_arn" {
  description = "ARN of the order events SNS topic"
  value       = aws_sns_topic.order_events.arn
}

output "sns_topic_name" {
  description = "Name of the order events SNS topic"
  value       = aws_sns_topic.order_events.name
}

output "sqs_queue_arn" {
  description = "ARN of the order email SQS queue"
  value       = aws_sqs_queue.order_email_queue.arn
}

output "sqs_queue_url" {
  description = "URL of the order email SQS queue"
  value       = aws_sqs_queue.order_email_queue.url
}

output "sqs_queue_name" {
  description = "Name of the order email SQS queue"
  value       = aws_sqs_queue.order_email_queue.name
}

output "sqs_dlq_arn" {
  description = "ARN of the dead letter queue"
  value       = aws_sqs_queue.order_email_dlq.arn
}
