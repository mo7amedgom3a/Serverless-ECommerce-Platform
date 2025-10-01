aws_region = "us-east-1"
environment = "dev"

# VPC and Networking
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b"]
ec2_ami_id           = "ami-00ca32bbc84273381" # Amazon Linux 2 AMI (adjust as needed)
ec2_instance_type    = "t2.micro"
ec2_key_name         = "aws_keys" # Replace with your EC2 key pair name

# RDS Database
db_username        = "admin"
db_password        = "mysql_password"
db_port            = 3306
db_name            = "ecommerce"
allocated_storage  = 10
instance_class     = "db.t3.micro"
multi_az           = false
create_rds_proxy   = true

# Lambda
users_ecr_image_uri = "058264170818.dkr.ecr.us-east-1.amazonaws.com/serverless-ecommerce-dev-users:latest"
lambda_timeout      = 30
lambda_memory_size  = 512
users_lambda_env_vars = {
  LOG_LEVEL = "INFO"
}

# API Gateway
cors_allowed_origins = ["*"] # Replace with your allowed origins in production