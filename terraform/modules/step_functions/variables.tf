variable "global" {
  description = "Global configuration"
  type = object({
    environment = string
    aws_region  = string
  })
}

variable "payment_lambda_arn" {
  description = "ARN of the Payment Lambda function"
  type        = string
}

variable "inventory_lambda_arn" {
  description = "ARN of the Inventory Lambda function"
  type        = string
}

variable "shipment_lambda_arn" {
  description = "ARN of the Shipment Lambda function"
  type        = string
}
