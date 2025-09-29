import logging
from fastapi import FastAPI

from app.config import settings
from app.models.base import init_db

from app.routers import users, health
import json
# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Users Service API",
    description="API for user management",
)

# Include routers
app.include_router(health.router, prefix="/api/v1")
app.include_router(users.router, prefix="/api/v1/users")

# Root endpoint
@app.get("/")
def root():
    """Root endpoint"""
    message = {
        "message": "Users Service is running"
    }
    return json.dumps(message)

