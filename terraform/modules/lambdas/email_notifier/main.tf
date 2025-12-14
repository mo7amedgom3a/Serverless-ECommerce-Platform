provider "aws" {
  region = var.global.aws_region
}

# IAM Role for Email Notifier Lambda
resource "aws_iam_role" "email_notifier_lambda_role" {
  name = "${var.global.environment}-email-notifier-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.global.environment}-email-notifier-lambda-role"
    Environment = var.global.environment
    Service     = "email-notifier"
  }
}

# Attach policies to Lambda role
resource "aws_iam_role_policy_attachment" "email_notifier_sqs_policy" {
  role       = aws_iam_role.email_notifier_lambda_role.name
  policy_arn = var.sqs_consume_policy_arn
}

resource "aws_iam_role_policy_attachment" "email_notifier_ses_policy" {
  role       = aws_iam_role.email_notifier_lambda_role.name
  policy_arn = var.ses_send_email_policy_arn
}

resource "aws_iam_role_policy_attachment" "email_notifier_cloudwatch_policy" {
  role       = aws_iam_role.email_notifier_lambda_role.name
  policy_arn = var.cloudwatch_policy_arn
}

# Lambda Function for Email Notifier
resource "aws_lambda_function" "email_notifier" {
  function_name = "${var.global.environment}-email-notifier"
  role          = aws_iam_role.email_notifier_lambda_role.arn
  package_type  = "Image"
  image_uri     = var.lambda_config.email_notifier_ecr_image_uri
  timeout       = var.lambda_config.timeout
  memory_size   = var.lambda_config.memory_size

  environment {
    variables = merge(
      var.lambda_config.env_vars,
      {
        ENVIRONMENT      = var.global.environment
        SES_SENDER_EMAIL = var.notification_config.ses_sender_email
        SES_REGION       = var.global.aws_region
      }
    )
  }

  tags = {
    Name        = "${var.global.environment}-email-notifier"
    Environment = var.global.environment
    Service     = "email-notifier"
  }
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "email_notifier_logs" {
  name              = "/aws/lambda/${aws_lambda_function.email_notifier.function_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.global.environment}-email-notifier-logs"
    Environment = var.global.environment
    Service     = "email-notifier"
  }
}

# SQS Event Source Mapping for Lambda
resource "aws_lambda_event_source_mapping" "email_notifier_sqs_trigger" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.email_notifier.arn
  batch_size       = 10
  enabled          = true

  # Partial batch response to handle individual message failures
  function_response_types = ["ReportBatchItemFailures"]

  # Scaling configuration
  scaling_config {
    maximum_concurrency = 10
  }
}
