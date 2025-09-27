provider "aws" {
  region = var.aws_region
}

# HTTP API Gateway
resource "aws_apigatewayv2_api" "api" {
  name          = "${var.environment}-ecommerce-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.cors_allowed_origins
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"]
    allow_headers = ["Content-Type", "Authorization", "X-Amz-Date", "X-Api-Key", "X-Amz-Security-Token", "Idempotency-Key"]
    max_age       = 300
  }

  tags = {
    Name        = "${var.environment}-ecommerce-api"
    Environment = var.environment
  }
}

# API Gateway stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      path           = "$context.path"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
      integrationLatency = "$context.integrationLatency"
    })
  }

  tags = {
    Name        = "${var.environment}-ecommerce-api-default-stage"
    Environment = var.environment
  }
}

# CloudWatch log group for API Gateway
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/${var.environment}-ecommerce-api"
  retention_in_days = 14

  tags = {
    Name        = "${var.environment}-api-gateway-logs"
    Environment = var.environment
  }
}

# Lambda integration for users service
resource "aws_apigatewayv2_integration" "users_lambda_integration" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.users_lambda_invoke_arn
  payload_format_version = "2.0"
  integration_method     = "POST"
}

# Route for users service
resource "aws_apigatewayv2_route" "users_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "ANY /users/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.users_lambda_integration.id}"
}

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "users_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.users_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/users/*"
}
