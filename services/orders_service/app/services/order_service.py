from typing import List, Optional

from app.repositories.order_repository import OrderRepository
from app.schemas.order import OrderCreate, OrderUpdate, OrderResponse


class OrderService:
    """Service for order business logic"""
    
    def __init__(self, repository: OrderRepository):
        self.repository = repository
    
    def get_order(self, order_id: int) -> Optional[OrderResponse]:
        """Get an order by ID"""
        order = self.repository.get_by_id(order_id)
        if not order:
            return None
        return OrderResponse.model_validate(order)
    
    def get_user_orders(self, user_id: int, skip: int = 0, limit: int = 100) -> List[OrderResponse]:
        """Get all orders for a specific user"""
        orders = self.repository.get_by_user_id(user_id, skip, limit)
        return [OrderResponse.model_validate(order) for order in orders]
    
    def list_orders(self, skip: int = 0, limit: int = 100) -> List[OrderResponse]:
        """Get a list of orders with pagination"""
        orders = self.repository.list_orders(skip, limit)
        return [OrderResponse.model_validate(order) for order in orders]
    
    def create_order(self, order_data: OrderCreate) -> OrderResponse:
        """Create a new order"""
        order = self.repository.create(order_data)
        return OrderResponse.model_validate(order)
    
    def update_order(self, order_id: int, order_data: OrderUpdate) -> Optional[OrderResponse]:
        """Update an order's information"""
        update_data = {k: v for k, v in order_data.model_dump().items() if v is not None}
        
        if not update_data:
            order = self.repository.get_by_id(order_id)
            return OrderResponse.model_validate(order) if order else None
        
        updated_order = self.repository.update(order_id, **update_data)
        if not updated_order:
            return None
        return OrderResponse.model_validate(updated_order)
    
    def delete_order(self, order_id: int) -> bool:
        """Delete an order"""
        return self.repository.delete(order_id)
