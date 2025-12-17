# -----------------------------------------------------
# STEP FUNCTIONS WORKFLOW ENDPOINT
# -----------------------------------------------------

# IAM Role for API Gateway to invoke Step Functions
resource "aws_iam_role" "api_gateway_step_functions_role" {
  count = var.step_functions_state_machine_arn != "" ? 1 : 0
  name  = "${var.global.environment}-api-gateway-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.global.environment}-api-gateway-step-functions-role"
    Environment = var.global.environment
  }
}

# IAM Policy for Step Functions invocation
resource "aws_iam_policy" "step_functions_invoke_policy" {
  count       = var.step_functions_state_machine_arn != "" ? 1 : 0
  name        = "${var.global.environment}-api-gateway-step-functions-invoke"
  description = "Allow API Gateway to start Step Functions executions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:StartExecution"
        ]
        Resource = var.step_functions_state_machine_arn
      }
    ]
  })

  tags = {
    Name        = "${var.global.environment}-api-gateway-step-functions-invoke"
    Environment = var.global.environment
  }
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "step_functions_invoke_attachment" {
  count      = var.step_functions_state_machine_arn != "" ? 1 : 0
  role       = aws_iam_role.api_gateway_step_functions_role[0].name
  policy_arn = aws_iam_policy.step_functions_invoke_policy[0].arn
}

# /workflow resource
resource "aws_api_gateway_resource" "workflow" {
  count       = var.step_functions_state_machine_arn != "" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "workflow"
}

# /workflow/start resource
resource "aws_api_gateway_resource" "workflow_start" {
  count       = var.step_functions_state_machine_arn != "" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.workflow[0].id
  path_part   = "start"
}

# POST method for /workflow/start
resource "aws_api_gateway_method" "workflow_start_post" {
  count         = var.step_functions_state_machine_arn != "" ? 1 : 0
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.workflow_start[0].id
  http_method   = "POST"
  authorization = "NONE"
}

# Step Functions integration
resource "aws_api_gateway_integration" "workflow_start_integration" {
  count       = var.step_functions_state_machine_arn != "" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.workflow_start[0].id
  http_method = aws_api_gateway_method.workflow_start_post[0].http_method

  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${var.global.aws_region}:states:action/StartExecution"
  credentials             = aws_iam_role.api_gateway_step_functions_role[0].arn

  request_templates = {
    "application/json" = <<EOF
{
  "input": "$util.escapeJavaScript($input.json('$'))",
  "stateMachineArn": "${var.step_functions_state_machine_arn}"
}
EOF
  }
}

# Method response for 200
resource "aws_api_gateway_method_response" "workflow_start_response_200" {
  count       = var.step_functions_state_machine_arn != "" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.workflow_start[0].id
  http_method = aws_api_gateway_method.workflow_start_post[0].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# Integration response
resource "aws_api_gateway_integration_response" "workflow_start_integration_response" {
  count       = var.step_functions_state_machine_arn != "" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.workflow_start[0].id
  http_method = aws_api_gateway_method.workflow_start_post[0].http_method
  status_code = aws_api_gateway_method_response.workflow_start_response_200[0].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = <<EOF
{
  "executionArn": "$input.path('$.executionArn')",
  "startDate": "$input.path('$.startDate')",
  "message": "Workflow execution started successfully"
}
EOF
  }
}

# OPTIONS method for CORS
resource "aws_api_gateway_method" "workflow_start_options" {
  count         = var.step_functions_state_machine_arn != "" ? 1 : 0
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.workflow_start[0].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# CORS integration
resource "aws_api_gateway_integration" "workflow_start_options_integration" {
  count       = var.step_functions_state_machine_arn != "" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.workflow_start[0].id
  http_method = aws_api_gateway_method.workflow_start_options[0].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# OPTIONS method response
resource "aws_api_gateway_method_response" "workflow_start_options_response" {
  count       = var.step_functions_state_machine_arn != "" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.workflow_start[0].id
  http_method = aws_api_gateway_method.workflow_start_options[0].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# OPTIONS integration response
resource "aws_api_gateway_integration_response" "workflow_start_options_integration_response" {
  count       = var.step_functions_state_machine_arn != "" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.workflow_start[0].id
  http_method = aws_api_gateway_method.workflow_start_options[0].http_method
  status_code = aws_api_gateway_method_response.workflow_start_options_response[0].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}
