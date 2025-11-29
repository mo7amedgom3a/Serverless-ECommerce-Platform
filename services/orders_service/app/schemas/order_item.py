from pydantic import BaseModel, Field
from decimal import Decimal


class OrderItemBase(BaseModel):
    """Base order item schema"""
    product_id: int
    quantity: int = Field(gt=0, default=1)
    price_at_order: Decimal = Field(gt=0, decimal_places=2)


class OrderItemCreate(OrderItemBase):
    """Schema for creating an order item"""
    pass


class OrderItemResponse(OrderItemBase):
    """Schema for order item responses"""
    order_item_id: int
    order_id: int
    
    class Config:
        from_attributes = True
