provider "aws" {
  region = var.global.aws_region
}

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "${var.global.environment}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.global.environment}-redis-subnet-group"
    Environment = var.global.environment
  }
}

# Security Group for Redis
resource "aws_security_group" "redis_sg" {
  name        = "${var.global.environment}-redis-sg"
  description = "Security group for ElastiCache Redis"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis port from Lambda"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.lambda_sg_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.global.environment}-redis-sg"
    Environment = var.global.environment
  }
}

# ElastiCache Parameter Group
resource "aws_elasticache_parameter_group" "redis_params" {
  name   = "${var.global.environment}-redis-params"
  family = var.redis_config.parameter_family

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  tags = {
    Name        = "${var.global.environment}-redis-params"
    Environment = var.global.environment
  }
}

# ElastiCache Replication Group (Redis Cluster)
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "${var.global.environment}-redis-cluster"
  description          = "Redis cluster for ${var.global.environment} environment"

  engine               = "redis"
  engine_version       = var.redis_config.engine_version
  node_type            = var.redis_config.node_type
  num_cache_clusters   = var.redis_config.num_cache_nodes
  parameter_group_name = aws_elasticache_parameter_group.redis_params.name

  port               = 6379
  subnet_group_name  = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids = [aws_security_group.redis_sg.id]

  # Encryption
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  # Automatic failover (requires at least 2 nodes)
  automatic_failover_enabled = var.redis_config.num_cache_nodes > 1
  multi_az_enabled           = var.redis_config.num_cache_nodes > 1

  # Maintenance
  maintenance_window       = "sun:05:00-sun:06:00"
  snapshot_window          = "03:00-04:00"
  snapshot_retention_limit = 5

  # Auto minor version upgrade
  auto_minor_version_upgrade = true

  # Notifications
  notification_topic_arn = var.sns_topic_arn != "" ? var.sns_topic_arn : null

  tags = {
    Name        = "${var.global.environment}-redis-cluster"
    Environment = var.global.environment
  }
}
