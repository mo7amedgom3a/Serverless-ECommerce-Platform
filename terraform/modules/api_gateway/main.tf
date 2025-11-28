provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------
# API GATEWAY - SHARED RESOURCES
# -----------------------------------------------------
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.environment}-api"
  description = "API Gateway for ${var.environment} environment"
}

# -----------------------------------------------------
# DEPLOYMENT AND STAGE
# -----------------------------------------------------
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.users_root_integration,
    aws_api_gateway_integration.users_proxy_integration,
    aws_api_gateway_integration.users_options,
    #aws_api_gateway_integration.products_any_integration,
    #aws_api_gateway_integration.products_options,
    #aws_api_gateway_integration.orders_any_integration,
    #aws_api_gateway_integration.orders_options
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.api.id,
      aws_api_gateway_integration.users_root_integration,
      aws_api_gateway_integration.users_proxy_integration,
      aws_api_gateway_integration.users_options,
      #aws_api_gateway_integration.products_any_integration,
      #aws_api_gateway_integration.products_options,
      #aws_api_gateway_integration.orders_any_integration,
      #aws_api_gateway_integration.orders_options,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name    = var.environment

  tags = {
    Name = "${var.environment}-api-stage"
  }
}