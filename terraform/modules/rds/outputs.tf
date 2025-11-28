output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.rds_instance.endpoint
}

output "rds_address" {
  description = "Address of the RDS instance"
  value       = aws_db_instance.rds_instance.address
}

output "rds_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.rds_instance.port
}

output "rds_username" {
  description = "Username for the RDS instance"
  value       = aws_db_instance.rds_instance.username
}

output "rds_name" {
  description = "Database name"
  value       = aws_db_instance.rds_instance.db_name
}

output "rds_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.rds_instance.arn
}

output "rds_proxy_endpoint" {
  description = "Endpoint of the RDS Proxy"
  value       = var.rds_config.create_proxy ? aws_db_proxy.rds_proxy[0].endpoint : ""
}

output "rds_password" {
  description = "Password for the RDS instance"
  value       = local.db_password
  sensitive   = true
}
