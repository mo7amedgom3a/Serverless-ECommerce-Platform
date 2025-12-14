# Global Configuration
global = {
  aws_region  = "us-east-1"
  environment = "prod"
}

# Networking Configuration
networking_config = {
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
}

# EC2 Configuration
ec2_config = {
  ami_id        = "ami-00ca32bbc84273381" # Amazon Linux 2 AMI (adjust as needed)
  instance_type = "t2.micro"
  key_name      = "my-aws-keys" # Replace with your EC2 key pair name
}

# RDS Configuration
rds_config = {
  db_name           = "ecommerce"
  db_username       = "admin"
  db_password       = "mysql_password"
  db_port           = 3306
  allocated_storage = 10
  instance_class    = "db.t3.micro"
  multi_az          = false
  create_proxy      = true
}

# Lambda Configuration
lambda_config = {
  users_ecr_image_uri = "016829298884.dkr.ecr.us-east-1.amazonaws.com/serverless-ecommerce-dev-users:latest"
  timeout             = 30
  memory_size         = 512
  env_vars = {
    LOG_LEVEL = "INFO"
  }
}

# API Gateway Configuration
api_gateway_config = {
  cors_allowed_origins = ["*"] # Replace with your allowed origins in production
}

# Notification Configuration
notification_config = {
  ses_sender_email             = "noreply@example.com" # Replace with your verified SES email
  email_notifier_ecr_image_uri = "016829298884.dkr.ecr.us-east-1.amazonaws.com/serverless-ecommerce-dev-email-notifier:latest"
}
