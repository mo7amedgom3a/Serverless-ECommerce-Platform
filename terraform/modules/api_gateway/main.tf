provider "aws" {
  region = var.aws_region
}
resource "aws_api_gateway_rest_api" "api" {
  name = "${var.environment}-api"
  description = "API Gateway for ${var.environment} environment"
}

# Root ANY method to forward / to users Lambda
resource "aws_api_gateway_method" "root_any" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_any_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.root_any.http_method
  type = "AWS_PROXY"
  uri = var.users_lambda_invoke_arn
  integration_http_method = "POST"
}

# user api resource
resource "aws_api_gateway_resource" "user_api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id = aws_api_gateway_rest_api.api.root_resource_id
  path_part = "users"
}

# /users/{proxy+}
resource "aws_api_gateway_resource" "user_api_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id = aws_api_gateway_resource.user_api.id
  path_part = "{proxy+}"
}

# Proxy resource method and integration
resource "aws_api_gateway_method" "user_api_proxy_any" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_api_proxy.id
  http_method = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "user_api_proxy_any_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_api_proxy.id
  http_method = aws_api_gateway_method.user_api_proxy_any.http_method
  type = "AWS_PROXY"
  uri = var.users_lambda_invoke_arn
  integration_http_method = "POST"
}

# Root /users ANY method
resource "aws_api_gateway_method" "user_api_root_any" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_api.id
  http_method = "ANY"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "user_api_root_any_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_api.id
  http_method = aws_api_gateway_method.user_api_root_any.http_method
  type = "AWS_PROXY"
  uri = var.users_lambda_invoke_arn
  integration_http_method = "POST"
}

# users options method
resource "aws_api_gateway_method" "user_api_options" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_api.id
  http_method = "OPTIONS"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "user_api_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_api.id
  http_method = aws_api_gateway_method.user_api_options.http_method
  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}
resource "aws_api_gateway_method_response"  "user_api_options_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_api.id
  http_method = aws_api_gateway_method.user_api_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_integration_response" "user_api_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.user_api.id
  http_method = aws_api_gateway_method.user_api_options.http_method
  status_code = aws_api_gateway_method_response.user_api_options_response.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
  }
}

# Lambda permission for API Gateway to invoke Lambda function
resource "aws_lambda_permission" "user_api_lambda_permission" {
  function_name = var.users_lambda_function_name
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api" {
    depends_on = [
      aws_api_gateway_integration.root_any_integration,
      aws_api_gateway_integration.user_api_root_any_integration,
      aws_api_gateway_integration.user_api_options_integration,
      aws_api_gateway_integration.user_api_proxy_any_integration,
    ]

    triggers = {
      redeployment = sha1(jsonencode([
        aws_api_gateway_rest_api.api.body,
        aws_api_gateway_integration.root_any_integration.uri,
        aws_api_gateway_integration.user_api_root_any_integration.uri,
        aws_api_gateway_integration.user_api_options_integration.uri,
        aws_api_gateway_integration.user_api_proxy_any_integration.uri,
      ]))
    }
    lifecycle {
      create_before_destroy = true
    }
    rest_api_id = aws_api_gateway_rest_api.api.id
  
}


resource "aws_api_gateway_stage" "main" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name = var.environment
  deployment_id = aws_api_gateway_deployment.api.id
  tags = {
    Name = "${var.environment}-api-stage"
  }
}