import os


class Settings:
    """Application settings loaded from environment variables"""
    
    # AWS Region
    AWS_REGION: str = os.environ.get("AWS_REGION", "us-east-1")
    
    # Database
    DB_HOST: str = os.environ.get("DB_HOST", "localhost")
    DB_PORT: str = os.environ.get("DB_PORT", "5432")
    DB_NAME: str = os.environ.get("DB_NAME", "ecommerce")
    DB_USER: str = os.environ.get("DB_USER", "postgres")
    DB_PASSWORD: str = os.environ.get("DB_PASSWORD", "postgres")
    
    # RDS Proxy
    RDS_PROXY_ENDPOINT: str = os.environ.get("RDS_PROXY_ENDPOINT", "")
    
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
