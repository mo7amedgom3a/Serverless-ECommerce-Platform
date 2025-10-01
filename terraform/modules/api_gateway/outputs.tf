output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_deployment.api.id
}

output "api_endpoint" {
  description = "Endpoint URL of the API Gateway"
  value       = aws_api_gateway_stage.main.invoke_url
}

output "stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_stage.main.stage_name
}

output "invoke_url" {
  description = "Invoke URL of the API Gateway"
  value       = aws_api_gateway_stage.main.invoke_url
}
