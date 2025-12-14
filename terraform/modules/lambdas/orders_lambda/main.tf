provider "aws" {
  region = var.global.aws_region
}

resource "aws_lambda_function" "orders_lambda" {
  function_name = "${var.global.environment}-orders-lambda"
  role          = aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = var.lambda_config.orders_ecr_image_uri
  timeout       = var.lambda_config.timeout
  memory_size   = var.lambda_config.memory_size

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }

  environment {
    variables = merge(var.lambda_config.env_vars, {
      ENVIRONMENT               = var.global.environment
      SECRETS_MANAGER_SECRET_ID = var.secrets_manager_secret_id
      SNS_TOPIC_ARN             = var.sns_topic_arn
      AWS_REGION                = var.global.aws_region
    })
  }

  tags = {
    Name        = "${var.global.environment}-orders-lambda"
    Environment = var.global.environment
    Service     = "orders"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.global.environment}-orders-lambda-role"

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
    Name        = "${var.global.environment}-orders-lambda-role"
    Environment = var.global.environment
    Service     = "orders"
  }
}

# Attach policies to the Lambda role
resource "aws_iam_role_policy_attachment" "secrets_manager_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = var.secrets_manager_policy_arn
}

resource "aws_iam_role_policy_attachment" "rds_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = var.rds_policy_arn
}

resource "aws_iam_role_policy_attachment" "vpc_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = var.vpc_policy_arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = var.cloudwatch_policy_arn
}

# Attach SNS publish policy for order notifications
resource "aws_iam_role_policy_attachment" "sns_publish_policy_attachment" {
  count      = var.sns_publish_policy_arn != null ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = var.sns_publish_policy_arn
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.orders_lambda.function_name}"
  retention_in_days = 14

  tags = {
    Name        = "${var.global.environment}-orders-lambda-logs"
    Environment = var.global.environment
    Service     = "orders"
  }
}
