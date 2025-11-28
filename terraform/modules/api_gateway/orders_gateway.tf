# # -----------------------------------------------------
# # ORDERS API GATEWAY CONFIGURATION
# # -----------------------------------------------------

# # Orders resource and proxy
# resource "aws_api_gateway_resource" "orders" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_rest_api.api.root_resource_id
#   path_part   = "orders"
# }

# resource "aws_api_gateway_resource" "orders_proxy" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_resource.orders.id
#   path_part   = "{proxy+}"
# }

# # Lambda integration for orders
# locals {
#   orders_lambda_integrations = {
#     root  = { resource_id = aws_api_gateway_resource.orders.id }
#     proxy = { resource_id = aws_api_gateway_resource.orders_proxy.id }
#   }
# }

# resource "aws_api_gateway_method" "orders_any_method" {
#   for_each      = local.orders_lambda_integrations
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   resource_id   = each.value.resource_id
#   http_method   = "ANY"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "orders_any_integration" {
#   for_each                = aws_api_gateway_method.orders_any_method
#   rest_api_id             = each.value.rest_api_id
#   resource_id             = each.value.resource_id
#   http_method             = each.value.http_method
#   type                    = "AWS_PROXY"
#   integration_http_method = "POST"
#   uri                     = var.orders_lambda_invoke_arn
# }

# # CORS configuration for orders
# resource "aws_api_gateway_method" "orders_options" {
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   resource_id   = aws_api_gateway_resource.orders.id
#   http_method   = "OPTIONS"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "orders_options" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   resource_id = aws_api_gateway_resource.orders.id
#   http_method = aws_api_gateway_method.orders_options.http_method
#   type        = "MOCK"

#   request_templates = {
#     "application/json" = "{\"statusCode\": 200}"
#   }
# }

# resource "aws_api_gateway_method_response" "orders_options" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   resource_id = aws_api_gateway_resource.orders.id
#   http_method = aws_api_gateway_method.orders_options.http_method
#   status_code = "200"
#   response_models = {
#     "application/json" = "Empty"
#   }
#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Origin"  = true
#     "method.response.header.Access-Control-Allow-Headers" = true
#     "method.response.header.Access-Control-Allow-Methods" = true
#   }
# }

# resource "aws_api_gateway_integration_response" "orders_options" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   resource_id = aws_api_gateway_resource.orders.id
#   http_method = aws_api_gateway_method.orders_options.http_method
#   status_code = aws_api_gateway_method_response.orders_options.status_code
#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Origin"  = "'*'"
#     "method.response.header.Access-Control-Allow-Headers" = "'*'"
#     "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
#   }
# }

# # Lambda permission for orders
# resource "aws_lambda_permission" "apigw_invoke_orders" {
#   statement_id  = "AllowAPIGatewayInvokeOrders"
#   action        = "lambda:InvokeFunction"
#   function_name = var.orders_lambda_function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
# }
