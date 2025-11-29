from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from decimal import Decimal

from app.schemas.order_item import OrderItemCreate, OrderItemResponse


class OrderBase(BaseModel):
    """Base order schema"""
    user_id: int
    status: str = Field(default="PENDING", pattern="^(PENDING|PAID|SHIPPED)$")
    order_total: Decimal = Field(gt=0, decimal_places=2)


class OrderCreate(BaseModel):
    """Schema for creating an order"""
    user_id: int
    items: List[OrderItemCreate] = Field(min_length=1)
    
    class Config:
        from_attributes = True


class OrderUpdate(BaseModel):
    """Schema for updating an order"""
    status: Optional[str] = Field(None, pattern="^(PENDING|PAID|SHIPPED)$")


class OrderResponse(BaseModel):
    """Schema for order responses"""
    order_id: int
    user_id: int
    status: str
    order_total: Decimal
    created_at: datetime
    items: List[OrderItemResponse] = []
    
    class Config:
        from_attributes = True
