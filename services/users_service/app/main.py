import logging
from fastapi import FastAPI

from app.config import settings
from app.models.base import init_db
from app.routers import users, health

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
    version="1.0.0",
    docs_url=f"{settings.API_PREFIX}/docs",
    redoc_url=f"{settings.API_PREFIX}/redoc",
    openapi_url=f"{settings.API_PREFIX}/openapi.json",
)

# Include routers
app.include_router(health.router, prefix=settings.API_PREFIX)
app.include_router(users.router, prefix=f"{settings.API_PREFIX}/users")

# Startup event
@app.on_event("startup")
def startup_event():
    """Initialize the application on startup"""
    logger.info("Starting Users Service")
    init_db()
    logger.info("Database initialized")

# Root endpoint
@app.get("/")
def root():
    """Root endpoint"""
    return {
        "service": "Users Service",
        "version": "1.0.0",
        "docs": f"{settings.API_PREFIX}/docs"
    }
