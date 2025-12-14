provider "aws" {
  region = var.global.aws_region
}

# Configure the backend for state storage (uncomment and configure as needed)
# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "serverless-ecommerce/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }

# VPC and Networking
module "networking" {
  source = "./modules/networking"

  global            = var.global
  networking_config = var.networking_config
}

# EC2 Instance
module "ec2" {
  source = "./modules/ec2"

  global           = var.global
  ec2_config       = var.ec2_config
  vpc_id           = module.networking.vpc_id
  public_subnet_id = module.networking.public_subnet_ids[0]
  ec2_rds_sg_id    = module.networking.ec2_rds_sg_id
}

# Secrets Manager for RDS credentials (created first to avoid circular dependency)
module "secrets_manager" {
  source = "./modules/secrets_manager"

  global             = var.global
  rds_config         = var.rds_config
  rds_address        = "" # Will be updated after RDS is created
  rds_endpoint       = "" # Will be updated after RDS is created
  rds_proxy_endpoint = "" # Will be updated after RDS is created
}

# RDS Database
module "rds" {
  source = "./modules/rds"

  global                     = var.global
  rds_config                 = var.rds_config
  private_subnet_ids         = module.networking.private_subnet_ids
  rds_security_group_id      = module.networking.rds_sg_id
  secrets_manager_secret_arn = module.secrets_manager.secret_arn
}

# Update the secret with actual RDS connection details
resource "aws_secretsmanager_secret_version" "rds_credentials_update" {
  secret_id = module.secrets_manager.secret_id
  secret_string = jsonencode({
    username           = module.rds.rds_username
    password           = module.rds.rds_password
    engine             = "mysql"
    host               = module.rds.rds_address
    port               = module.rds.rds_port
    dbname             = module.rds.rds_name
    endpoint           = module.rds.rds_endpoint
    rds_proxy_endpoint = module.rds.rds_proxy_endpoint
  })
}

# IAM Policies
module "iam" {
  source = "./modules/iam"

  global            = var.global
  secrets_arns      = [module.secrets_manager.secret_arn]
  rds_resource_arns = [module.rds.rds_arn]
}

# ElastiCache Redis for Caching
module "elasticache" {
  source = "./modules/elasticache"

  global             = var.global
  redis_config       = var.redis_config
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  lambda_sg_id       = module.networking.lambda_sg_id
}

# Users Lambda
module "users_lambda" {
  source = "./modules/lambdas/users_lambda"

  global                     = var.global
  lambda_config              = var.lambda_config
  private_subnet_ids         = module.networking.private_subnet_ids
  lambda_sg_id               = module.networking.lambda_sg_id
  secrets_manager_secret_id  = module.secrets_manager.secret_id
  secrets_manager_policy_arn = module.iam.secrets_manager_policy_arn
  rds_policy_arn             = module.iam.rds_access_policy_arn
  vpc_policy_arn             = module.iam.lambda_vpc_execution_policy_arn
  cloudwatch_policy_arn      = module.iam.cloudwatch_logs_policy_arn
}

# Products Lambda
module "products_lambda" {
  source = "./modules/lambdas/products_lambda"

  global                     = var.global
  lambda_config              = var.lambda_config
  private_subnet_ids         = module.networking.private_subnet_ids
  lambda_sg_id               = module.networking.lambda_sg_id
  secrets_manager_secret_id  = module.secrets_manager.secret_id
  secrets_manager_policy_arn = module.iam.secrets_manager_policy_arn
  rds_policy_arn             = module.iam.rds_access_policy_arn
  vpc_policy_arn             = module.iam.lambda_vpc_execution_policy_arn
  cloudwatch_policy_arn      = module.iam.cloudwatch_logs_policy_arn
  redis_endpoint             = module.elasticache.primary_endpoint
  redis_port                 = module.elasticache.port
}

# Orders Lambda
module "orders_lambda" {
  source = "./modules/lambdas/orders_lambda"

  global                     = var.global
  lambda_config              = var.lambda_config
  private_subnet_ids         = module.networking.private_subnet_ids
  lambda_sg_id               = module.networking.lambda_sg_id
  secrets_manager_secret_id  = module.secrets_manager.secret_id
  secrets_manager_policy_arn = module.iam.secrets_manager_policy_arn
  rds_policy_arn             = module.iam.rds_access_policy_arn
  vpc_policy_arn             = module.iam.lambda_vpc_execution_policy_arn
  cloudwatch_policy_arn      = module.iam.cloudwatch_logs_policy_arn
  sns_topic_arn              = module.sns_sqs.sns_topic_arn
  sns_publish_policy_arn     = module.iam_notifications.sns_publish_policy_arn
}

# API Gateway
module "api_gateway" {
  source = "./modules/api_gateway"

  global                        = var.global
  api_gateway_config            = var.api_gateway_config
  users_lambda_invoke_arn       = module.users_lambda.lambda_function_invoke_arn
  users_lambda_function_name    = module.users_lambda.lambda_function_name
  products_lambda_invoke_arn    = module.products_lambda.lambda_function_invoke_arn
  products_lambda_function_name = module.products_lambda.lambda_function_name
  orders_lambda_invoke_arn      = module.orders_lambda.lambda_function_invoke_arn
  orders_lambda_function_name   = module.orders_lambda.lambda_function_name
}

# SNS and SQS for Order Notifications
module "sns_sqs" {
  source = "./modules/sns_sqs"

  global = var.global
}

# Update IAM with SNS/SQS/SES policies
module "iam_notifications" {
  source = "./modules/iam"

  global            = var.global
  secrets_arns      = [module.secrets_manager.secret_arn]
  rds_resource_arns = [module.rds.rds_arn]
  sns_topic_arns    = [module.sns_sqs.sns_topic_arn]
  sqs_queue_arns    = [module.sns_sqs.sqs_queue_arn]
  enable_ses_policy = true
}

# Email Notifier Lambda
module "email_notifier" {
  source = "./modules/lambdas/email_notifier"

  global = var.global
  lambda_config = {
    email_notifier_ecr_image_uri = var.notification_config.email_notifier_ecr_image_uri
    timeout                      = 60
    memory_size                  = 256
    env_vars = {
      LOG_LEVEL = "INFO"
    }
  }
  notification_config       = var.notification_config
  sqs_queue_arn             = module.sns_sqs.sqs_queue_arn
  sqs_consume_policy_arn    = module.iam_notifications.sqs_consume_policy_arn
  ses_send_email_policy_arn = module.iam_notifications.ses_send_email_policy_arn
  cloudwatch_policy_arn     = module.iam_notifications.cloudwatch_logs_policy_arn
}
