from typing import List, Optional

from app.repositories.order_repository import OrderRepository
from app.schemas.order import OrderCreate, OrderUpdate, OrderResponse


class OrderService:
    """Service for order business logic"""
    
    def __init__(self, repository: OrderRepository, notification_service=None):
        self.repository = repository
        self.notification_service = notification_service
    
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
    
    def create_order(self, order_data: OrderCreate, user_email: str) -> OrderResponse:
        """Create a new order"""
        order = self.repository.create(order_data)
        order_response = OrderResponse.model_validate(order)
        
        # Publish order created event
        if self.notification_service:
            items_data = [
                {
                    "product_id": item.product_id,
                    "quantity": item.quantity,
                    "price_at_order": str(item.price_at_order)
                }
                for item in order_response.items
            ]
            
            self.notification_service.publish_order_event(
                order_id=order_response.order_id,
                user_id=order_response.user_id,
                user_email=user_email,
                status=order_response.status,
                order_total=order_response.order_total,
                items=items_data,
                created_at=order_response.created_at.isoformat()
            )
        
        return order_response
    
    def update_order(self, order_id: int, order_data: OrderUpdate, user_email: str = None) -> Optional[OrderResponse]:
        """Update an order's information"""
        # Get current order to check if status changed
        current_order = self.repository.get_by_id(order_id)
        if not current_order:
            return None
        
        update_data = {k: v for k, v in order_data.model_dump().items() if v is not None}
        
        if not update_data:
            return OrderResponse.model_validate(current_order)
        
        # Check if status is being updated
        status_changed = 'status' in update_data and update_data['status'] != current_order.status
        
        updated_order = self.repository.update(order_id, **update_data)
        if not updated_order:
            return None
        
        order_response = OrderResponse.model_validate(updated_order)
        
        # Publish order updated event if status changed
        if status_changed and self.notification_service and user_email:
            items_data = [
                {
                    "product_id": item.product_id,
                    "quantity": item.quantity,
                    "price_at_order": str(item.price_at_order)
                }
                for item in order_response.items
            ]
            
            self.notification_service.publish_order_event(
                order_id=order_response.order_id,
                user_id=order_response.user_id,
                user_email=user_email,
                status=order_response.status,
                order_total=order_response.order_total,
                items=items_data,
                created_at=order_response.created_at.isoformat()
            )
        
        return order_response
    
    def delete_order(self, order_id: int) -> bool:
        """Delete an order"""
        return self.repository.delete(order_id)
