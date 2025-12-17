output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.order_workflow.arn
}

output "state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = aws_sfn_state_machine.order_workflow.name
}

output "state_machine_id" {
  description = "ID of the Step Functions state machine"
  value       = aws_sfn_state_machine.order_workflow.id
}

output "step_functions_role_arn" {
  description = "ARN of the Step Functions IAM role"
  value       = aws_iam_role.step_functions_role.arn
}
