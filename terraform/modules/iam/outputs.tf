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

output "sns_publish_policy_arn" {
  description = "ARN of the SNS publish policy"
  value       = length(aws_iam_policy.sns_publish) > 0 ? aws_iam_policy.sns_publish[0].arn : null
}

output "sqs_consume_policy_arn" {
  description = "ARN of the SQS consume policy"
  value       = length(aws_iam_policy.sqs_consume) > 0 ? aws_iam_policy.sqs_consume[0].arn : null
}

output "ses_send_email_policy_arn" {
  description = "ARN of the SES send email policy"
  value       = length(aws_iam_policy.ses_send_email) > 0 ? aws_iam_policy.ses_send_email[0].arn : null
}
