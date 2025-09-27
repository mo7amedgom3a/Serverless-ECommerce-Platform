from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session
from sqlalchemy import text

from app.models.base import get_db
from app.config import settings

router = APIRouter(tags=["health"])


@router.get("/health")
def health_check(
    response: Response,
    db: Session = Depends(get_db)
):
    """Health check endpoint for the service"""
    status_code = status.HTTP_200_OK
    health_data = {
        "status": "ok",
        "version": "1.0.0",
        "aws_region": settings.AWS_REGION,
        "database": "unknown"
    }
    
    # Check database connection
    try:
        # Execute a simple query to check the database connection
        result = db.execute(text("SELECT 1")).scalar()
        if result == 1:
            health_data["database"] = "connected"
        else:
            health_data["database"] = "error"
            status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
    except Exception as e:
        health_data["database"] = "error"
        health_data["database_error"] = str(e)
        status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
    
    response.status_code = status_code
    return health_data
