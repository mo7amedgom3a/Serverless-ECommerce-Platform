import logging
from datetime import datetime
from typing import List

from app.models.cart_item import CartItem
from app.repositories.cart_repository import CartRepository
from app.schemas.cart import CartItemCreate, CartItemUpdate, CartItemResponse, CartResponse

logger = logging.getLogger(__name__)


class CartService:
    """Service layer for cart business logic"""
    
    def __init__(self, cart_repository: CartRepository):
        self.cart_repo = cart_repository
    
    def get_cart(self, user_id: str) -> CartResponse:
        """Get user's cart with calculated totals"""
        items = self.cart_repo.get_user_cart(user_id)
        
        # Convert to response DTOs
        item_responses = []
        total_price = 0.0
        total_items = 0
        
        for item in items:
            subtotal = item.price * item.quantity
            total_price += subtotal
            total_items += item.quantity
            
            item_responses.append(CartItemResponse(
                product_id=item.product_id,
                product_name=item.product_name,
                quantity=item.quantity,
                price=item.price,
                subtotal=subtotal,
                added_at=item.added_at
            ))
        
        return CartResponse(
            user_id=user_id,
            items=item_responses,
            total_items=total_items,
            total_price=round(total_price, 2)
        )
    
    def add_item(self, user_id: str, item_create: CartItemCreate) -> CartItemResponse:
        """Add item to cart"""
        # Create cart item
        cart_item = CartItem(
            user_id=user_id,
            item_id=CartItem.create_item_id(item_create.product_id),
            product_id=item_create.product_id,
            product_name=item_create.product_name,
            quantity=item_create.quantity,
            price=item_create.price,
            added_at=datetime.utcnow().isoformat(),
            ttl=None  # Will be set in repository
        )
        
        # Save to repository
        saved_item = self.cart_repo.add_item(cart_item)
        
        # Return response
        return CartItemResponse(
            product_id=saved_item.product_id,
            product_name=saved_item.product_name,
            quantity=saved_item.quantity,
            price=saved_item.price,
            subtotal=saved_item.price * saved_item.quantity,
            added_at=saved_item.added_at
        )
    
    def update_item(self, user_id: str, product_id: int, item_update: CartItemUpdate) -> CartItemResponse:
        """Update item quantity"""
        updated_item = self.cart_repo.update_quantity(user_id, product_id, item_update.quantity)
        
        if not updated_item:
            raise ValueError(f"Item with product_id {product_id} not found in cart")
        
        return CartItemResponse(
            product_id=updated_item.product_id,
            product_name=updated_item.product_name,
            quantity=updated_item.quantity,
            price=updated_item.price,
            subtotal=updated_item.price * updated_item.quantity,
            added_at=updated_item.added_at
        )
    
    def remove_item(self, user_id: str, product_id: int) -> None:
        """Remove item from cart"""
        self.cart_repo.remove_item(user_id, product_id)
        logger.info(f"Removed product {product_id} from cart for user {user_id}")
    
    def clear_cart(self, user_id: str) -> None:
        """Clear all items from cart"""
        self.cart_repo.clear_cart(user_id)
        logger.info(f"Cleared cart for user {user_id}")
