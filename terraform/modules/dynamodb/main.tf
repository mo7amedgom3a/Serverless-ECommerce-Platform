provider "aws" {
  region = var.global.aws_region
}

# DynamoDB Table for Shopping Carts
resource "aws_dynamodb_table" "carts" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "item_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "item_id"
    type = "S"
  }

  attribute {
    name = "product_id"
    type = "N"
  }

  # Global Secondary Index for querying by product
  global_secondary_index {
    name            = "ProductIndex"
    hash_key        = "product_id"
    projection_type = "ALL"
  }

  # TTL for automatic cart expiration (30 days)
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  # Point-in-time recovery for data protection
  point_in_time_recovery {
    enabled = true
  }

  # Server-side encryption
  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = var.table_name
    Environment = var.global.environment
    Service     = "cart"
  }
}
