from sqlalchemy.orm import Session
from typing import List, Optional
from decimal import Decimal

from app.models.order import Order
from app.models.order_item import OrderItem
from app.schemas.order import OrderCreate


class OrderRepository:
    """Repository for order database operations"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_by_id(self, order_id: int) -> Optional[Order]:
        """Get an order by ID"""
        return self.db.query(Order).filter(Order.order_id == order_id).first()
    
    def get_by_user_id(self, user_id: int, skip: int = 0, limit: int = 100) -> List[Order]:
        """Get all orders for a specific user"""
        return self.db.query(Order).filter(Order.user_id == user_id).offset(skip).limit(limit).all()
    
    def list_orders(self, skip: int = 0, limit: int = 100) -> List[Order]:
        """Get a list of orders with pagination"""
        return self.db.query(Order).offset(skip).limit(limit).all()
    
    def create(self, order_data: OrderCreate) -> Order:
        """Create a new order with order items"""
        # Calculate order total from items
        order_total = sum(item.price_at_order * item.quantity for item in order_data.items)
        
        # Create the order
        order = Order(
            user_id=order_data.user_id,
            status="PENDING",
            order_total=order_total
        )
        self.db.add(order)
        self.db.flush()  # Flush to get the order_id
        
        # Create order items
        for item_data in order_data.items:
            order_item = OrderItem(
                order_id=order.order_id,
                product_id=item_data.product_id,
                quantity=item_data.quantity,
                price_at_order=item_data.price_at_order
            )
            self.db.add(order_item)
        
        self.db.commit()
        self.db.refresh(order)
        return order
    
    def update(self, order_id: int, **kwargs) -> Optional[Order]:
        """Update order attributes"""
        order = self.get_by_id(order_id)
        if not order:
            return None
        
        for key, value in kwargs.items():
            if hasattr(order, key):
                setattr(order, key, value)
        
        self.db.commit()
        self.db.refresh(order)
        return order
    
    def delete(self, order_id: int) -> bool:
        """Delete an order by ID"""
        order = self.get_by_id(order_id)
        if not order:
            return False
        
        self.db.delete(order)
        self.db.commit()
        return True
