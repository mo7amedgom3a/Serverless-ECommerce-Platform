from sqlalchemy import Column, Integer, String, DECIMAL, TIMESTAMP, ForeignKey, func
from sqlalchemy.orm import relationship

from app.models.base import Base


class Order(Base):
    """Order model for database representation"""
    __tablename__ = "orders"

    order_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    status = Column(String(50), nullable=False, default="PENDING")  # PENDING, PAID, SHIPPED
    order_total = Column(DECIMAL(10, 2), nullable=False)
    created_at = Column(TIMESTAMP, server_default=func.current_timestamp())

    # Relationship to order items
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")
