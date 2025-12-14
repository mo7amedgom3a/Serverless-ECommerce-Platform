provider "aws" {
  region = var.global.aws_region
}

# SNS Topic for Order Events
resource "aws_sns_topic" "order_events" {
  name              = "${var.global.environment}-order-events-topic"
  display_name      = "Order Events Topic"
  kms_master_key_id = "alias/aws/sns"

  tags = {
    Name        = "${var.global.environment}-order-events-topic"
    Environment = var.global.environment
    Service     = "orders"
  }
}

# Dead Letter Queue for failed messages
resource "aws_sqs_queue" "order_email_dlq" {
  name                      = "${var.global.environment}-order-email-dlq"
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Name        = "${var.global.environment}-order-email-dlq"
    Environment = var.global.environment
    Service     = "email-notifier"
  }
}

# SQS Queue for Email Notifications
resource "aws_sqs_queue" "order_email_queue" {
  name                       = "${var.global.environment}-order-email-queue"
  visibility_timeout_seconds = 300    # 5 minutes (Lambda timeout * 6)
  message_retention_seconds  = 345600 # 4 days
  receive_wait_time_seconds  = 20     # Long polling

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.order_email_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name        = "${var.global.environment}-order-email-queue"
    Environment = var.global.environment
    Service     = "email-notifier"
  }
}

# SQS Queue Policy to allow SNS to send messages
resource "aws_sqs_queue_policy" "order_email_queue_policy" {
  queue_url = aws_sqs_queue.order_email_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "SQS:SendMessage"
        Resource = aws_sqs_queue.order_email_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.order_events.arn
          }
        }
      }
    ]
  })
}

# SNS Subscription to SQS
resource "aws_sns_topic_subscription" "order_events_to_email_queue" {
  topic_arn = aws_sns_topic.order_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.order_email_queue.arn

  # Filter policy to only receive order-related events (optional)
  filter_policy = jsonencode({
    event_type = ["order.created", "order.pending", "order.paid", "order.shipped", "order.completed"]
  })
}
