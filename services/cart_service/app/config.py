import os
import logging
from typing import Optional

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

class Config:
    """Application configuration"""
    
    def __init__(self):
        self.environment = os.getenv('ENVIRONMENT', 'dev')
        self.log_level = os.getenv('LOG_LEVEL', 'INFO')
        self.aws_region = os.getenv('AWS_REGION', 'us-east-1')
        self.dynamodb_table_name = os.getenv('DYNAMODB_TABLE_NAME', 'dev-carts')
        self.cart_ttl_days = int(os.getenv('CART_TTL_DAYS', '30'))
        
        # Set log level
        logging.getLogger().setLevel(getattr(logging, self.log_level))
    
    def get_dynamodb_endpoint(self) -> Optional[str]:
        """Get DynamoDB endpoint (for local development)"""
        if self.environment == 'dev':
            return os.getenv('DYNAMODB_ENDPOINT_URL')
        return None

# Global config instance
config = Config()
