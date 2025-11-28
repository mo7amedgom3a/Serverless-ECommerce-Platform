output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

# EC2 outputs
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.ec2_instance_id
}

output "ec2_instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2.ec2_instance_public_ip
}


# RDS outputs
output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = module.rds.rds_endpoint
}

output "rds_address" {
  description = "Address of the RDS instance"
  value       = module.rds.rds_address
}

output "rds_port" {
  description = "Port of the RDS instance"
  value       = module.rds.rds_port
  sensitive   = true
}

output "rds_name" {
  description = "Database name"
  value       = module.rds.rds_name
  sensitive   = true
}

output "rds_proxy_endpoint" {
  description = "Endpoint of the RDS Proxy"
  value       = module.rds.rds_proxy_endpoint
  sensitive   = true
}

# Secrets Manager outputs
output "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = module.secrets_manager.secret_arn
}

output "secrets_manager_secret_name" {
  description = "Name of the Secrets Manager secret"
  value       = module.secrets_manager.secret_name
}

# # Lambda outputs
# output "users_lambda_function_name" {
#   description = "Name of the users Lambda function"
#   value       = module.users_lambda.lambda_function_name
# }

# output "users_lambda_function_arn" {
#   description = "ARN of the users Lambda function"
#   value       = module.users_lambda.lambda_function_arn
# }

# # API Gateway outputs
# output "api_endpoint" {
#   description = "Endpoint URL of the API Gateway"
#   value       = module.api_gateway.api_endpoint
# }

# output "api_invoke_url" {
#   description = "Invoke URL of the API Gateway"
#   value       = module.api_gateway.invoke_url
# }

# output "users_api_url" {
#   description = "URL for the users API"
#   value       = "${module.api_gateway.invoke_url}/users"
# }
