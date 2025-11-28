import os
import json
import logging
import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger(__name__)

class Settings:
    """Application settings loaded from environment variables"""
    ENVIRONMENT: str = os.environ.get("ENVIRONMENT", "dev")
    LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO")
    

    def __init__(self):
        if self.ENVIRONMENT == "dev":
            self.load_local_env_variables()
        else:
            self.load_prod_env_variables()

    def load_local_env_variables(self):
        self.DB_HOST = os.environ.get("DB_HOST", "localhost")
        self.DB_PORT = os.environ.get("DB_PORT", "3306")
        self.DB_NAME = os.environ.get("DB_NAME", "ecommerce")
        self.DB_USER = os.environ.get("DB_USER", "root")
        self.DB_PASSWORD = os.environ.get("DB_PASSWORD", "2003")

    def load_prod_env_variables(self):
        # load from secrets manager
        try:
            # First try to get from environment variables
            self.DB_HOST = os.environ.get("DB_HOST")
            self.DB_PORT = os.environ.get("DB_PORT")
            self.DB_NAME = os.environ.get("DB_NAME")
            self.DB_USER = os.environ.get("DB_USER")
            self.DB_PASSWORD = os.environ.get("DB_PASSWORD")
            
            # If any of the required database settings are missing, fetch from Secrets Manager
            if not all([self.DB_HOST, self.DB_PORT, self.DB_NAME, self.DB_USER, self.DB_PASSWORD]):
                logger.info("Some database settings not found in environment variables, fetching from Secrets Manager")
                
                # Create a Secrets Manager client
                session = boto3.session.Session()
                client = session.client(service_name='secretsmanager')
                
                # Get the secret value
                secret_name = f"{self.ENVIRONMENT}/rds/credentials"
                response = client.get_secret_value(SecretId=secret_name)
                
                # Parse the secret JSON
                secret = json.loads(response['SecretString'])
                
                # Set database connection parameters from secrets
                self.DB_HOST = secret.get('host', 'localhost')
                self.DB_PORT = str(secret.get('port', '3306'))
                self.DB_NAME = secret.get('dbname', 'ecommerce')
                self.DB_USER = secret.get('username', 'admin')
                self.DB_PASSWORD = secret.get('password', '')
                
                logger.info(f"Successfully loaded database configuration from Secrets Manager for {self.ENVIRONMENT} environment")
            else:
                logger.info("Using database configuration from environment variables")
                
        except ClientError as e:
            logger.error(f"Failed to retrieve secret from Secrets Manager: {e}")
            raise
        except Exception as e:
            logger.error(f"Error loading production environment variables: {e}")
            raise
        
    @property
    def database_url(self) -> str:
        """Construct database URL for MySQL"""
        return f"mysql+pymysql://{self.DB_USER}:{self.DB_PASSWORD}@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"

# Create a global settings object
settings = Settings()