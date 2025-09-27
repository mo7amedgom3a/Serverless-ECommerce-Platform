from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime


class UserBase(BaseModel):
    """Base user schema"""
    name: str
    email: EmailStr


class UserCreate(UserBase):
    """Schema for creating a user"""
    password: str
    address: Optional[str] = None


class UserUpdate(BaseModel):
    """Schema for updating a user"""
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    password: Optional[str] = None
    address: Optional[str] = None


class UserResponse(UserBase):
    """Schema for user responses"""
    user_id: int
    address: Optional[str] = None
    created_at: datetime
    
    class Config:
        from_attributes = True
