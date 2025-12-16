from fastapi import FastAPI
import logging

from app.config import config
from app.routers import cart

# Configure logging
logging.basicConfig(
    level=getattr(logging, config.log_level),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

# Create FastAPI application
app = FastAPI(
    title="Cart Service",
    description="Shopping cart management service with DynamoDB",
    version="1.0.0"
)

# Include routers
app.include_router(cart.router)


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "service": "cart-service",
        "status": "healthy",
        "environment": config.environment
    }


@app.get("/health")
async def health_check():
    """Detailed health check"""
    return {
        "status": "healthy",
        "service": "cart-service",
        "environment": config.environment,
        "dynamodb_table": config.dynamodb_table_name
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
