import os
import logging

logger = logging.getLogger(__name__)


class Settings:
    """Application settings loaded from environment variables"""
    ENVIRONMENT: str = os.environ.get("ENVIRONMENT", "dev")
    LOG_LEVEL: str = os.environ.get("LOG_LEVEL", "INFO")
    SES_SENDER_EMAIL: str = os.environ.get("SES_SENDER_EMAIL", "noreply@example.com")
    SES_REGION: str = os.environ.get("SES_REGION", "us-east-1")


# Create a global settings object
settings = Settings()
