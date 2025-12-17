output "lambda_function_arn" {
  description = "ARN of the Shipment Lambda function"
  value       = aws_lambda_function.shipment_lambda.arn
}

output "lambda_function_name" {
  description = "Name of the Shipment Lambda function"
  value       = aws_lambda_function.shipment_lambda.function_name
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Shipment Lambda function"
  value       = aws_lambda_function.shipment_lambda.invoke_arn
}

output "lambda_role_arn" {
  description = "ARN of the Shipment Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}
