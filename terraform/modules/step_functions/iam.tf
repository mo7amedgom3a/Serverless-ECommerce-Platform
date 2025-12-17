# IAM Role for Step Functions
resource "aws_iam_role" "step_functions_role" {
  name = "${var.global.environment}-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.global.environment}-step-functions-role"
    Environment = var.global.environment
    Service     = "step-functions"
  }
}

# IAM Policy for Lambda Invocation
resource "aws_iam_policy" "lambda_invoke_policy" {
  name        = "${var.global.environment}-step-functions-lambda-invoke"
  description = "Allow Step Functions to invoke Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          var.payment_lambda_arn,
          var.inventory_lambda_arn,
          var.shipment_lambda_arn
        ]
      }
    ]
  })

  tags = {
    Name        = "${var.global.environment}-step-functions-lambda-invoke"
    Environment = var.global.environment
  }
}

# IAM Policy for CloudWatch Logs
resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "${var.global.environment}-step-functions-cloudwatch"
  description = "Allow Step Functions to write to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.global.environment}-step-functions-cloudwatch"
    Environment = var.global.environment
  }
}

# Attach Lambda Invoke Policy
resource "aws_iam_role_policy_attachment" "lambda_invoke_attachment" {
  role       = aws_iam_role.step_functions_role.name
  policy_arn = aws_iam_policy.lambda_invoke_policy.arn
}

# Attach CloudWatch Logs Policy
resource "aws_iam_role_policy_attachment" "cloudwatch_logs_attachment" {
  role       = aws_iam_role.step_functions_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}
