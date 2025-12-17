output "lambda_function_arn" {
  description = "ARN of the Inventory Lambda function"
  value       = aws_lambda_function.inventory_lambda.arn
}

output "lambda_function_name" {
  description = "Name of the Inventory Lambda function"
  value       = aws_lambda_function.inventory_lambda.function_name
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Inventory Lambda function"
  value       = aws_lambda_function.inventory_lambda.invoke_arn
}

output "lambda_role_arn" {
  description = "ARN of the Inventory Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}
