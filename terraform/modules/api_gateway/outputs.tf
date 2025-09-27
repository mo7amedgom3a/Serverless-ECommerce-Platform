output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_apigatewayv2_api.api.id
}

output "api_endpoint" {
  description = "Endpoint URL of the API Gateway"
  value       = aws_apigatewayv2_api.api.api_endpoint
}

output "stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_apigatewayv2_stage.default.name
}

output "invoke_url" {
  description = "Invoke URL of the API Gateway"
  value       = aws_apigatewayv2_stage.default.invoke_url
}
