import logging
from fastapi import FastAPI

from app.config import settings
from app.models.base import init_db
from fastapi.responses import RedirectResponse

from app.routers import orders

# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Orders Service API",
    description="API for order management",
)


app.include_router(orders.router, prefix="/orders")

