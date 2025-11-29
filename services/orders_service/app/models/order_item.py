from sqlalchemy import Column, Integer, DECIMAL, ForeignKey
from sqlalchemy.orm import relationship

from app.models.base import Base


class OrderItem(Base):
    """OrderItem model for database representation"""
    __tablename__ = "order_items"

    order_item_id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.order_id"), nullable=False)
    product_id = Column(Integer, ForeignKey("products.product_id"), nullable=False)
    quantity = Column(Integer, nullable=False, default=1)
    price_at_order = Column(DECIMAL(10, 2), nullable=False)

    # Relationship to order
    order = relationship("Order", back_populates="items")
