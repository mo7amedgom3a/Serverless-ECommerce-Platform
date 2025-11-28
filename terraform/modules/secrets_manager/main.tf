provider "aws" {
  region = var.global.aws_region
}

# Secrets Manager secret for RDS credentials
resource "aws_secretsmanager_secret" "rds_credentials" {
  name                    = "${var.global.environment}/rds/credentials"
  description             = "RDS credentials for ${var.global.environment} environment"
  recovery_window_in_days = 0 # Set to 0 to immediately delete the secret after deletion
  tags = {
    Name        = "${var.global.environment}-rds-credentials"
    Environment = var.global.environment
  }
}

# Secret version with RDS values
resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username           = var.rds_config.db_username
    password           = var.rds_config.db_password
    engine             = "mysql"
    host               = var.rds_address
    port               = var.rds_config.db_port
    dbname             = var.rds_config.db_name
    endpoint           = var.rds_endpoint
    rds_proxy_endpoint = var.rds_proxy_endpoint
  })
}
