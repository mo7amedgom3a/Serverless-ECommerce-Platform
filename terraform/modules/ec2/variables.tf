# Global Configuration
variable "global" {
  description = "Global configuration settings"
  type = object({
    aws_region  = string
    environment = string
  })
}

# EC2 Configuration
variable "ec2_config" {
  description = "EC2 instance configuration"
  type = object({
    ami_id        = string
    instance_type = string
    key_name      = string
  })
}

# Module Dependencies (from networking module)
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet for EC2 instance"
  type        = string
}

variable "ec2_rds_sg_id" {
  description = "ID of the EC2 to RDS security group"
  type        = string
}
