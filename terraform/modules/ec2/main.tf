provider "aws" {
  region = var.global.aws_region
}

# EC2 Instance Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "${var.global.environment}-ec2-sg"
  description = "Security group for EC2 instance"
  vpc_id      = var.vpc_id

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.global.environment}-ec2-sg"
  }
}

# EC2 Instance for RDS purposes
resource "aws_instance" "rds_admin" {
  ami                    = var.ec2_config.ami_id
  instance_type          = var.ec2_config.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id, var.ec2_rds_sg_id]
  key_name               = var.ec2_config.key_name

  tags = {
    Name = "${var.global.environment}-rds-admin"
  }
}
