# Global Configuration
variable "global" {
  description = "Global configuration settings used across all modules"
  type = object({
    aws_region  = string
    environment = string
  })
  default = {
    aws_region  = "us-east-1"
    environment = "prod"
  }
}

# Networking Configuration
variable "networking_config" {
  description = "VPC and networking configuration"
  type = object({
    vpc_cidr             = string
    public_subnet_cidrs  = list(string)
    private_subnet_cidrs = list(string)
    availability_zones   = list(string)
  })
  default = {
    vpc_cidr             = "10.0.0.0/16"
    public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
    availability_zones   = ["us-east-1a", "us-east-1b"]
  }
}

# EC2 Configuration
variable "ec2_config" {
  description = "EC2 instance configuration"
  type = object({
    ami_id        = string
    instance_type = string
    key_name      = string
  })
  default = {
    ami_id        = "ami-00ca32bbc84273381" # Amazon Linux 2 AMI (adjust as needed)
    instance_type = "t2.micro"
    key_name      = "my-aws-keys"
  }
}

# RDS Configuration
variable "rds_config" {
  description = "RDS database configuration"
  type = object({
    db_name           = string
    db_username       = string
    db_password       = string
    db_port           = number
    allocated_storage = number
    instance_class    = string
    multi_az          = bool
    create_proxy      = bool
  })
  sensitive = true
  default = {
    db_name           = "ecommerce"
    db_username       = "admin"
    db_password       = "mysql_password"
    db_port           = 3306
    allocated_storage = 10
    instance_class    = "db.t3.micro"
    multi_az          = false
    create_proxy      = true
  }
}

# Lambda Configuration
variable "lambda_config" {
  description = "Lambda function configuration"
  type = object({
    users_ecr_image_uri = string
    timeout             = number
    memory_size         = number
    env_vars            = map(string)
  })
  default = {
    users_ecr_image_uri = "016829298884.dkr.ecr.us-east-1.amazonaws.com/serverless-ecommerce-dev-users:latest"
    timeout             = 30
    memory_size         = 512
    env_vars = {
      LOG_LEVEL   = "INFO"
      ENVIRONMENT = "prod"
    }
  }
}

# API Gateway Configuration
variable "api_gateway_config" {
  description = "API Gateway configuration"
  type = object({
    cors_allowed_origins = list(string)
  })
  default = {
    cors_allowed_origins = ["*"]
  }
}

# Notification Configuration
variable "notification_config" {
  description = "Notification service configuration"
  type = object({
    ses_sender_email             = string
    email_notifier_ecr_image_uri = string
  })
  default = {
    ses_sender_email             = "noreply@example.com"
    email_notifier_ecr_image_uri = "016829298884.dkr.ecr.us-east-1.amazonaws.com/serverless-ecommerce-dev-email-notifier:latest"
  }
}
