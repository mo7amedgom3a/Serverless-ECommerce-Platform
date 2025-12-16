output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.carts.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.carts.arn
}

output "table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.carts.id
}

output "gsi_name" {
  description = "Name of the Global Secondary Index"
  value       = "ProductIndex"
}
