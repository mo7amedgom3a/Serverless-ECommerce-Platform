provider "aws" {
  region = var.aws_region
}

# IAM Policy for Lambda to access Secrets Manager
resource "aws_iam_policy" "secrets_manager_access" {
  name        = "${var.environment}-secrets-manager-access-policy"
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
    Name        = "${var.environment}-secrets-manager-access-policy"
    Environment = var.environment
  }
}

# IAM Policy for Lambda to access RDS
resource "aws_iam_policy" "rds_access" {
  name        = "${var.environment}-rds-access-policy"
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
    Name        = "${var.environment}-rds-access-policy"
    Environment = var.environment
  }
}

# IAM Policy for Lambda VPC execution
resource "aws_iam_policy" "lambda_vpc_execution" {
  name        = "${var.environment}-lambda-vpc-execution-policy"
  description = "Policy for Lambda VPC execution"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-lambda-vpc-execution-policy"
    Environment = var.environment
  }
}

# IAM Policy for CloudWatch Logs
resource "aws_iam_policy" "cloudwatch_logs" {
  name        = "${var.environment}-cloudwatch-logs-policy"
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
    Name        = "${var.environment}-cloudwatch-logs-policy"
    Environment = var.environment
  }
}
