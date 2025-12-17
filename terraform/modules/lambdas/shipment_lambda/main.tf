provider "aws" {
  region = var.global.aws_region
}

resource "aws_lambda_function" "shipment_lambda" {
  function_name = "${var.global.environment}-shipment-lambda"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = var.lambda_config.shipment_ecr_image_uri
  timeout       = var.lambda_config.timeout
  memory_size   = var.lambda_config.memory_size

  environment {
    variables = merge(var.lambda_config.env_vars, {
      ENVIRONMENT = var.global.environment
      AWS_REGION  = var.global.aws_region
    })
  }

  tags = {
    Name        = "${var.global.environment}-shipment-lambda"
    Environment = var.global.environment
    Service     = "shipment"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.global.environment}-shipment-lambda-role"

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
    Name        = "${var.global.environment}-shipment-lambda-role"
    Environment = var.global.environment
    Service     = "shipment"
  }
}

# Attach policies to the Lambda role
resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = var.cloudwatch_policy_arn
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.shipment_lambda.function_name}"
  retention_in_days = 14

  tags = {
    Name        = "${var.global.environment}-shipment-lambda-logs"
    Environment = var.global.environment
    Service     = "shipment"
  }
}
