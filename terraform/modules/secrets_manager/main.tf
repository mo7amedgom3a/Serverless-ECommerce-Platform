provider "aws" {
  region = var.aws_region
}

# Secrets Manager secret for RDS credentials
resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "${var.environment}/rds/credentials"
  description = "RDS credentials for ${var.environment} environment"
  
  tags = {
    Name        = "${var.environment}-rds-credentials"
    Environment = var.environment
  }
}

# Secret version with RDS values
resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username            = var.rds_username
    password            = var.rds_password
    engine              = "mysql"
    host                = var.rds_address
    port                = var.rds_port
    dbname              = var.rds_name
    endpoint            = var.rds_endpoint
    rds_proxy_endpoint  = var.rds_proxy_endpoint
  })
}