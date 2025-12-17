# Global Configuration
variable "global" {
  description = "Global configuration settings"
  type = object({
    aws_region  = string
    environment = string
  })
}

# API Gateway Configuration
variable "api_gateway_config" {
  description = "API Gateway configuration"
  type = object({
    cors_allowed_origins = list(string)
  })
}

# Module Dependencies
variable "users_lambda_invoke_arn" {
  description = "Invoke ARN of the users Lambda function"
  type        = string
}

variable "users_lambda_function_name" {
  description = "Name of the users Lambda function"
  type        = string
}

variable "products_lambda_invoke_arn" {
  description = "Invoke ARN of the products Lambda function"
  type        = string
}

variable "products_lambda_function_name" {
  description = "Name of the products Lambda function"
  type        = string
}

variable "orders_lambda_invoke_arn" {
  description = "Invoke ARN of the orders Lambda function"
  type        = string
}

variable "orders_lambda_function_name" {
  description = "Name of the orders Lambda function"
  type        = string
}

variable "cart_lambda_invoke_arn" {
  description = "Invoke ARN of the cart Lambda function"
  type        = string
}

variable "cart_lambda_function_name" {
  description = "Name of the cart Lambda function"
  type        = string
}

variable "step_functions_state_machine_arn" {
  description = "ARN of the Step Functions state machine for workflow orchestration"
  type        = string
  default     = ""
}

