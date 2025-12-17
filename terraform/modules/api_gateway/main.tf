provider "aws" {
  region = var.global.aws_region
}

# -----------------------------------------------------
# API GATEWAY - SHARED RESOURCES
# -----------------------------------------------------
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.global.environment}-api"
  description = "API Gateway for ${var.global.environment} environment"
}

# -----------------------------------------------------
# ROOT RESOURCE MOCK INTEGRATION
# -----------------------------------------------------
resource "aws_api_gateway_method" "root_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_rest_api.api.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.root_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "root_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.root_method.http_method
  status_code = "200"

  response_models = {
    "text/html" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "root_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.root_method.http_method
  status_code = aws_api_gateway_method_response.root_response.status_code

  response_templates = {
    "text/html" = <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Serverless E-Commerce Platform</title>
    <style>
        body { font-family: sans-serif; text-align: center; padding: 50px; }
        h1 { color: #333; }
        p { color: #666; }
        code { background: #f4f4f4; padding: 2px 5px; border-radius: 3px; }
    </style>
</head>
<body>
    <h1>Welcome to Serverless E-Commerce Platform</h1>
    <p>To invoke the Users Service, use <code>/users/any</code></p>
</body>
</html>
EOF
  }
}

# -----------------------------------------------------
# DEPLOYMENT AND STAGE
# -----------------------------------------------------
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.users_root_integration,
    aws_api_gateway_integration.users_proxy_integration,
    aws_api_gateway_integration.users_options,
    aws_api_gateway_integration.root_integration,
    #aws_api_gateway_integration.products_any_integration,
    #aws_api_gateway_integration.products_options,
    #aws_api_gateway_integration.orders_any_integration,
    #aws_api_gateway_integration.orders_options
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(concat([
      aws_api_gateway_rest_api.api.id,
      aws_api_gateway_integration.users_root_integration,
      aws_api_gateway_integration.users_proxy_integration,
      aws_api_gateway_integration.users_options,
      aws_api_gateway_integration.root_integration,
      #aws_api_gateway_integration.products_any_integration,
      #aws_api_gateway_integration.products_options,
      #aws_api_gateway_integration.orders_any_integration,
      #aws_api_gateway_integration.orders_options,
      ],
      var.step_functions_state_machine_arn != "" ? [
        aws_api_gateway_integration.workflow_start_integration[0],
        aws_api_gateway_integration.workflow_start_options_integration[0]
      ] : []
    )))
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name    = var.global.environment

  tags = {
    Name = "${var.global.environment}-api-stage"
  }
}
