from pydantic import BaseModel, Field
from typing import List


class CartItemCreate(BaseModel):
    """Schema for creating a cart item"""
    product_id: int = Field(..., gt=0, description="Product ID")
    product_name: str = Field(..., min_length=1, max_length=200, description="Product name")
    quantity: int = Field(..., gt=0, description="Quantity must be greater than 0")
    price: float = Field(..., gt=0, description="Price must be greater than 0")


class CartItemUpdate(BaseModel):
    """Schema for updating cart item quantity"""
    quantity: int = Field(..., gt=0, description="Quantity must be greater than 0")


class CartItemResponse(BaseModel):
    """Schema for cart item response"""
    product_id: int
    product_name: str
    quantity: int
    price: float
    subtotal: float
    added_at: str
    
    class Config:
        from_attributes = True


class CartResponse(BaseModel):
    """Schema for cart response"""
    user_id: str
    items: List[CartItemResponse]
    total_items: int
    total_price: float
    
    class Config:
        from_attributes = True
