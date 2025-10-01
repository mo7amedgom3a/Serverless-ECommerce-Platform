provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

# Public subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
  }
}

# Private subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# use existing eip
data "aws_eip" "nat" {
  filter {
    name   = "tag:Name"
    values = ["nat-eip"]
  }
}
# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "eipalloc-07e30e087ab001852"
  subnet_id     = aws_subnet.public[0].id
  
  tags = {
    Name = "${var.environment}-nat-gw"
  }
  
  depends_on = [aws_internet_gateway.igw]
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}-public-route-table"
  }
}

# Route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.environment}-private-route-table"
  }
}

# Route table associations for public subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route table associations for private subnets
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Security Group for EC2 to RDS connection
resource "aws_security_group" "ec2_rds_sg" {
  name        = "${var.environment}-ec2-rds-sg"
  description = "Security group for EC2 to RDS connection"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-ec2-rds-sg"
  }
}

# Security Group for Lambda to RDS connection
resource "aws_security_group" "lambda_rds_sg" {
  name        = "${var.environment}-lambda-rds-sg"
  description = "Security group for Lambda to RDS connection"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-lambda-rds-sg"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id

  # Allow mysql traffic from EC2 security group
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_rds_sg.id]
  }

  # Allow MySQL traffic from Lambda security group
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_rds_sg.id]
  }

  tags = {
    Name = "${var.environment}-rds-sg"
  }
}

# EC2 Instance Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "${var.environment}-ec2-sg"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.main.id

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
    Name = "${var.environment}-ec2-sg"
  }
}

# EC2 Instance for RDS purposes
resource "aws_instance" "rds_admin" {
  ami                    = var.ec2_ami_id
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id, aws_security_group.ec2_rds_sg.id]
  key_name               = var.ec2_key_name

  tags = {
    Name = "${var.environment}-rds-admin"
  }
}
