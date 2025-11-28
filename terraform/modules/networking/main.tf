provider "aws" {
  region = var.global.aws_region
}

resource "aws_vpc" "main" {
  cidr_block           = var.networking_config.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.global.environment}-vpc"
  }
}

# Public subnets
resource "aws_subnet" "public" {
  count                   = length(var.networking_config.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.networking_config.public_subnet_cidrs[count.index]
  availability_zone       = var.networking_config.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.global.environment}-public-subnet-${count.index + 1}"
  }
}

# Private subnets
resource "aws_subnet" "private" {
  count             = length(var.networking_config.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.networking_config.private_subnet_cidrs[count.index]
  availability_zone = var.networking_config.availability_zones[count.index]

  tags = {
    Name = "${var.global.environment}-private-subnet-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.global.environment}-igw"
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
  allocation_id = "eipalloc-007ad83d8f3de853f"
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.global.environment}-nat-gw"
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
    Name = "${var.global.environment}-public-route-table"
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
    Name = "${var.global.environment}-private-route-table"
  }
}

# Route table associations for public subnets
resource "aws_route_table_association" "public" {
  count          = length(var.networking_config.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route table associations for private subnets
resource "aws_route_table_association" "private" {
  count          = length(var.networking_config.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Security Group for EC2 to RDS connection
resource "aws_security_group" "ec2_rds_sg" {
  name        = "${var.global.environment}-ec2-rds-sg"
  description = "Security group for EC2 to RDS connection"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.global.environment}-ec2-rds-sg"
  }
}

# Security Group for Lambda to RDS connection
resource "aws_security_group" "lambda_rds_sg" {
  name        = "${var.global.environment}-lambda-rds-sg"
  description = "Security group for Lambda to RDS connection"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.global.environment}-lambda-rds-sg"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.global.environment}-rds-sg"
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
    Name = "${var.global.environment}-rds-sg"
  }
}

