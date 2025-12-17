provider "aws" {
  region = var.global.aws_region
}

# Step Functions State Machine
resource "aws_sfn_state_machine" "order_workflow" {
  name     = "${var.global.environment}-order-workflow"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = templatefile("${path.module}/state_machine.json", {
    payment_lambda_arn   = var.payment_lambda_arn
    inventory_lambda_arn = var.inventory_lambda_arn
    shipment_lambda_arn  = var.shipment_lambda_arn
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.step_functions_log_group.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  tags = {
    Name        = "${var.global.environment}-order-workflow"
    Environment = var.global.environment
    Service     = "step-functions"
  }
}

# CloudWatch Log Group for Step Functions
resource "aws_cloudwatch_log_group" "step_functions_log_group" {
  name              = "/aws/stepfunctions/${var.global.environment}-order-workflow"
  retention_in_days = 14

  tags = {
    Name        = "${var.global.environment}-step-functions-logs"
    Environment = var.global.environment
    Service     = "step-functions"
  }
}
