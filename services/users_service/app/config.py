import os
import json
import logging
import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger(__name__)

class Settings:
    """Application settings loaded from environment variables and Secrets Manager"""
    
    # AWS Region
    AWS_REGION: str = os.environ.get("AWS_REGION", "us-east-1")
    
    # Secret Manager
    SECRETS_MANAGER_SECRET_ARN: str = os.environ.get("SECRETS_MANAGER_SECRET_ARN", "")
    
    # Database credentials (will be overridden by Secrets Manager if available)
    DB_HOST: str = os.environ.get("DB_HOST", "localhost")
    DB_PORT: str = os.environ.get("DB_PORT", "5432")
    DB_NAME: str = os.environ.get("DB_NAME", "ecommerce")
    DB_USER: str = os.environ.get("DB_USER", "postgres")
    DB_PASSWORD: str = os.environ.get("DB_PASSWORD", "postgres")
    
    # RDS Proxy
    RDS_PROXY_ENDPOINT: str = os.environ.get("RDS_PROXY_ENDPOINT", "")
    
    def __init__(self):
        """Initialize settings and load secrets if available"""
        if self.SECRETS_MANAGER_SECRET_ARN:
            self._load_secrets()
    
    def _load_secrets(self):
        """Load secrets from AWS Secrets Manager"""
        try:
            # Create a Secrets Manager client
            session = boto3.session.Session()
            client = session.client(
                service_name='secretsmanager',
                region_name=self.AWS_REGION
            )
            
            # Get the secret value
            get_secret_value_response = client.get_secret_value(
                SecretId=self.SECRETS_MANAGER_SECRET_ID
            )
            
            # Parse the secret string
            secret_string = get_secret_value_response['SecretString']
            secret = json.loads(secret_string)
            
            # Update settings with values from Secrets Manager
            self.DB_USER = secret.get('username', self.DB_USER)
            self.DB_PASSWORD = secret.get('password', self.DB_PASSWORD)
            self.DB_HOST = secret.get('host', self.DB_HOST)
            self.DB_PORT = secret.get('port', self.DB_PORT)
            self.DB_NAME = secret.get('dbname', self.DB_NAME)
            self.RDS_PROXY_ENDPOINT = secret.get('rds_proxy_endpoint', self.RDS_PROXY_ENDPOINT)
            
            logger.info("Successfully loaded database credentials from Secrets Manager")
        except ClientError as e:
            logger.error(f"Failed to load secrets: {e}")
            # Continue with environment variables
    
    @property
    def database_url(self) -> str:
        """Construct database URL"""
        if self.RDS_PROXY_ENDPOINT:
            return f"postgresql+psycopg://{self.DB_USER}:{self.DB_PASSWORD}@{self.RDS_PROXY_ENDPOINT}/{self.DB_NAME}"
        return f"postgresql+psycopg://{self.DB_USER}:{self.DB_PASSWORD}@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
    
    # API Configuration
    API_PREFIX: str = "/api/v1"
    DEBUG: bool = os.environ.get("DEBUG", "False").lower() == "true"
    
    # Logging
    LOG_LEVEL: str = os.environ.get("LOG_LEVEL", "INFO")


# Create a global settings object
settings = Settings()