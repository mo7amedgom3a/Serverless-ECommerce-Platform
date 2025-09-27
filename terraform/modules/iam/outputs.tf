output "secrets_manager_policy_arn" {
  description = "ARN of the Secrets Manager access policy"
  value       = aws_iam_policy.secrets_manager_access.arn
}

output "rds_access_policy_arn" {
  description = "ARN of the RDS access policy"
  value       = aws_iam_policy.rds_access.arn
}

output "lambda_vpc_execution_policy_arn" {
  description = "ARN of the Lambda VPC execution policy"
  value       = aws_iam_policy.lambda_vpc_execution.arn
}

output "cloudwatch_logs_policy_arn" {
  description = "ARN of the CloudWatch Logs policy"
  value       = aws_iam_policy.cloudwatch_logs.arn
}
