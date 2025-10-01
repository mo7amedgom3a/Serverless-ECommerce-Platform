import logging
from fastapi import FastAPI
from fastapi.responses import RedirectResponse

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
app.include_router(health.router)
app.include_router(users.router)

# Root endpoint
@app.get("/")
def root():
    """Redirect root to /users"""
    return RedirectResponse(url="/users")

