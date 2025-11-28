provider "aws" {
  region = var.aws_region
}

# Random password for RDS if not provided
resource "random_password" "rds_password" {
  count   = var.db_password == "" ? 1 : 0
  length  = 16
  special = false
}

locals {
  db_password = var.db_password == "" ? random_password.rds_password[0].result : var.db_password
}

# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.environment}-rds-subnet-group"
  description = "RDS subnet group for ${var.environment}"
  subnet_ids  = var.private_subnet_ids

  tags = {
    Name        = "${var.environment}-rds-subnet-group"
    Environment = var.environment
  }
}

# RDS Parameter Group
resource "aws_db_parameter_group" "rds_parameter_group" {
  name   = "${var.environment}-rds-parameter-group"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }

  tags = {
    Name        = "${var.environment}-rds-parameter-group"
    Environment = var.environment
  }
}

# RDS Instance
resource "aws_db_instance" "rds_instance" {
  identifier              = "${var.environment}-rds-instance"
  allocated_storage       = var.allocated_storage
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.instance_class
  db_name                 = var.db_name
  username                = var.db_username
  password                = local.db_password
  parameter_group_name    = aws_db_parameter_group.rds_parameter_group.name
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [var.rds_security_group_id]
  publicly_accessible     = false
  skip_final_snapshot     = true
  multi_az                = var.multi_az
  port                    = var.db_port

  tags = {
    Name        = "${var.environment}-rds-instance"
    Environment = var.environment
  }
}

# RDS Proxy (Optional)
resource "aws_db_proxy" "rds_proxy" {
  count                  = var.create_proxy ? 1 : 0
  name                   = "${var.environment}-rds-proxy"
  debug_logging          = false
  engine_family          = "MYSQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = aws_iam_role.rds_proxy_role[0].arn
  vpc_security_group_ids = [var.rds_security_group_id]
  vpc_subnet_ids         = var.private_subnet_ids

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"
    secret_arn  = var.secrets_manager_secret_arn
  }

  tags = {
    Name        = "${var.environment}-rds-proxy"
    Environment = var.environment
  }

  depends_on = [aws_db_instance.rds_instance]
}

# RDS Proxy Target Group
resource "aws_db_proxy_default_target_group" "rds_proxy_target_group" {
  count         = var.create_proxy ? 1 : 0
  db_proxy_name = aws_db_proxy.rds_proxy[0].name

  connection_pool_config {
    max_connections_percent      = 100
    max_idle_connections_percent = 50
    connection_borrow_timeout    = 120
  }
}

# RDS Proxy Target Registration
resource "aws_db_proxy_target" "rds_proxy_target" {
  count                  = var.create_proxy ? 1 : 0
  db_instance_identifier = aws_db_instance.rds_instance.identifier
  db_proxy_name          = aws_db_proxy.rds_proxy[0].name
  target_group_name      = aws_db_proxy_default_target_group.rds_proxy_target_group[0].name
}


# IAM Role for RDS Proxy
resource "aws_iam_role" "rds_proxy_role" {
  count = var.create_proxy ? 1 : 0
  name  = "${var.environment}-rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-rds-proxy-role"
    Environment = var.environment
  }
}

# IAM Policy for RDS Proxy to access Secrets Manager
resource "aws_iam_policy" "rds_proxy_policy" {
  count       = var.create_proxy ? 1 : 0
  name        = "${var.environment}-rds-proxy-policy"
  description = "Policy for RDS Proxy to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Effect   = "Allow"
        Resource = var.secrets_manager_secret_arn
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-rds-proxy-policy"
    Environment = var.environment
  }
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "rds_proxy_policy_attachment" {
  count      = var.create_proxy ? 1 : 0
  role       = aws_iam_role.rds_proxy_role[0].name
  policy_arn = aws_iam_policy.rds_proxy_policy[0].arn
}
