# Cart Service API Gateway Integration

# /cart resource
resource "aws_api_gateway_resource" "cart" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "cart"
}

# /cart/{user_id} resource
resource "aws_api_gateway_resource" "cart_user_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.cart.id
  path_part   = "{user_id}"
}

# GET /cart/{user_id} - Get cart
resource "aws_api_gateway_method" "get_cart" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.cart_user_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_cart" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.cart_user_id.id
  http_method             = aws_api_gateway_method.get_cart.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.cart_lambda_invoke_arn
}

# DELETE /cart/{user_id} - Clear cart
resource "aws_api_gateway_method" "clear_cart" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.cart_user_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "clear_cart" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.cart_user_id.id
  http_method             = aws_api_gateway_method.clear_cart.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.cart_lambda_invoke_arn
}

# /cart/{user_id}/items resource
resource "aws_api_gateway_resource" "cart_items" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.cart_user_id.id
  path_part   = "items"
}

# POST /cart/{user_id}/items - Add item
resource "aws_api_gateway_method" "add_item" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.cart_items.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "add_item" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.cart_items.id
  http_method             = aws_api_gateway_method.add_item.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.cart_lambda_invoke_arn
}

# /cart/{user_id}/items/{product_id} resource
resource "aws_api_gateway_resource" "cart_item" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.cart_items.id
  path_part   = "{product_id}"
}

# PUT /cart/{user_id}/items/{product_id} - Update quantity
resource "aws_api_gateway_method" "update_item" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.cart_item.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "update_item" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.cart_item.id
  http_method             = aws_api_gateway_method.update_item.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.cart_lambda_invoke_arn
}

# DELETE /cart/{user_id}/items/{product_id} - Remove item
resource "aws_api_gateway_method" "remove_item" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.cart_item.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "remove_item" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.cart_item.id
  http_method             = aws_api_gateway_method.remove_item.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.cart_lambda_invoke_arn
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway_cart" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.cart_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
