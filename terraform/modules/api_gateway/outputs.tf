output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.api.id
}

output "api_endpoint" {
  description = "Endpoint URL of the API Gateway"
  value       = aws_api_gateway_stage.stage.invoke_url
}

output "stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_stage.stage.stage_name
}

output "invoke_url" {
  description = "Invoke URL of the API Gateway"
  value       = aws_api_gateway_stage.stage.invoke_url
}
