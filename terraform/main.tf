provider "aws" {
  region = var.aws_region
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

  aws_region           = var.aws_region
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  ec2_ami_id           = var.ec2_ami_id
  ec2_instance_type    = var.ec2_instance_type
  ec2_key_name         = var.ec2_key_name
}

# RDS Database
module "rds" {
  source = "./modules/rds"

  aws_region            = var.aws_region
  environment           = var.environment
  private_subnet_ids    = module.networking.private_subnet_ids
  rds_security_group_id = module.networking.rds_sg_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  db_port               = var.db_port
  allocated_storage     = var.allocated_storage
  instance_class        = var.instance_class
  multi_az              = var.multi_az
  create_proxy          = var.create_rds_proxy
}

# Secrets Manager for RDS credentials
module "secrets_manager" {
  source = "./modules/secrets_manager"

  aws_region         = var.aws_region
  environment        = var.environment
  rds_username       = module.rds.rds_username
  rds_password       = module.rds.rds_password
  rds_address        = module.rds.rds_address
  rds_endpoint       = module.rds.rds_endpoint
  rds_port           = module.rds.rds_port
  rds_name           = module.rds.rds_name
  rds_proxy_endpoint = module.rds.rds_proxy_endpoint
}

# IAM Policies
module "iam" {
  source = "./modules/iam"

  aws_region        = var.aws_region
  environment       = var.environment
  secrets_arns      = [module.secrets_manager.secret_arn]
  rds_resource_arns = [module.rds.rds_arn]
}

# Lambda Function for Users Service
# module "users_lambda" {
#   source = "./modules/lambdas/users_lambda"

#   aws_region               = var.aws_region
#   environment              = var.environment
#   ecr_image_uri            = var.users_ecr_image_uri
#   private_subnet_ids       = module.networking.private_subnet_ids
#   lambda_sg_id             = module.networking.lambda_rds_sg_id
#   lambda_timeout           = var.lambda_timeout
#   lambda_memory_size       = var.lambda_memory_size
#   environment_variables    = var.users_lambda_env_vars
#   secrets_manager_secret_id = module.secrets_manager.secret_name
#   secrets_manager_policy_arn = module.iam.secrets_manager_policy_arn
#   rds_policy_arn           = module.iam.rds_access_policy_arn
#   vpc_policy_arn           = module.iam.lambda_vpc_execution_policy_arn
#   cloudwatch_policy_arn    = module.iam.cloudwatch_logs_policy_arn
# }

# API Gateway
# module "api_gateway" {
#   source = "./modules/api_gateway"

#   aws_region                = var.aws_region
#   environment               = var.environment
#   cors_allowed_origins      = var.cors_allowed_origins
#   users_lambda_invoke_arn   = module.users_lambda.lambda_function_invoke_arn
#   users_lambda_function_name = module.users_lambda.lambda_function_name
# }