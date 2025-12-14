output "primary_endpoint" {
  description = "Primary endpoint for Redis cluster"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "reader_endpoint" {
  description = "Reader endpoint for Redis cluster"
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}

output "port" {
  description = "Redis port"
  value       = aws_elasticache_replication_group.redis.port
}

output "configuration_endpoint" {
  description = "Configuration endpoint for Redis cluster"
  value       = aws_elasticache_replication_group.redis.configuration_endpoint_address
}

output "security_group_id" {
  description = "ID of the Redis security group"
  value       = aws_security_group.redis_sg.id
}

output "replication_group_id" {
  description = "ID of the replication group"
  value       = aws_elasticache_replication_group.redis.id
}
