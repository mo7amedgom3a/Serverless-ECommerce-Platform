provider "aws" {
  region = var.global.aws_region
}

# IAM Policy for Lambda to access Secrets Manager
resource "aws_iam_policy" "secrets_manager_access" {
  name        = "${var.global.environment}-secrets-manager-access-policy"
  description = "Policy for accessing Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = var.secrets_arns
      }
    ]
  })

  tags = {
    Name        = "${var.global.environment}-secrets-manager-access-policy"
    Environment = var.global.environment
  }
}

# IAM Policy for Lambda to access RDS
resource "aws_iam_policy" "rds_access" {
  name        = "${var.global.environment}-rds-access-policy"
  description = "Policy for accessing RDS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds-db:connect"
        ]
        Effect   = "Allow"
        Resource = var.rds_resource_arns
      }
    ]
  })

  tags = {
    Name        = "${var.global.environment}-rds-access-policy"
    Environment = var.global.environment
  }
}

# IAM Policy for Lambda VPC execution
resource "aws_iam_policy" "lambda_vpc_execution" {
  name        = "${var.global.environment}-lambda-vpc-execution-policy"
  description = "Policy for Lambda VPC execution"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.global.environment}-lambda-vpc-execution-policy"
    Environment = var.global.environment
  }
}

# IAM Policy for CloudWatch Logs
resource "aws_iam_policy" "cloudwatch_logs" {
  name        = "${var.global.environment}-cloudwatch-logs-policy"
  description = "Policy for CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  tags = {
    Name        = "${var.global.environment}-cloudwatch-logs-policy"
    Environment = var.global.environment
  }
}

# IAM Policy for SNS Publish
resource "aws_iam_policy" "sns_publish" {
  count       = length(var.sns_topic_arns) > 0 ? 1 : 0
  name        = "${var.global.environment}-sns-publish-policy"
  description = "Policy for publishing to SNS topics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = var.sns_topic_arns
      }
    ]
  })

  tags = {
    Name        = "${var.global.environment}-sns-publish-policy"
    Environment = var.global.environment
  }
}

# IAM Policy for SQS Consume
resource "aws_iam_policy" "sqs_consume" {
  count       = length(var.sqs_queue_arns) > 0 ? 1 : 0
  name        = "${var.global.environment}-sqs-consume-policy"
  description = "Policy for consuming from SQS queues"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Effect   = "Allow"
        Resource = var.sqs_queue_arns
      }
    ]
  })

  tags = {
    Name        = "${var.global.environment}-sqs-consume-policy"
    Environment = var.global.environment
  }
}

# IAM Policy for SES Send Email
resource "aws_iam_policy" "ses_send_email" {
  count       = var.enable_ses_policy ? 1 : 0
  name        = "${var.global.environment}-ses-send-email-policy"
  description = "Policy for sending emails via SES"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.global.environment}-ses-send-email-policy"
    Environment = var.global.environment
  }
}

# DynamoDB Access Policy
resource "aws_iam_policy" "dynamodb_access" {
  count = var.dynamodb_table_arn != "" ? 1 : 0
  name  = "${var.global.environment}-dynamodb-access-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem",
          "dynamodb:BatchGetItem"
        ]
        Resource = [
          var.dynamodb_table_arn,
          "${var.dynamodb_table_arn}/index/*"
        ]
      }
    ]
  })

  tags = {
    Name        = "${var.global.environment}-dynamodb-access-policy"
    Environment = var.global.environment
  }
}
