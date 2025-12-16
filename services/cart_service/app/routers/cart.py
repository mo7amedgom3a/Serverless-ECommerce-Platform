from fastapi import APIRouter, HTTPException, status
import logging

from app.schemas.cart import CartItemCreate, CartItemUpdate, CartItemResponse, CartResponse
from app.services.cart_service import CartService
from app.repositories.cart_repository import CartRepository

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/cart", tags=["cart"])

# Initialize repository and service
cart_repository = CartRepository()
cart_service = CartService(cart_repository)


@router.get("/{user_id}", response_model=CartResponse, status_code=status.HTTP_200_OK)
async def get_cart(user_id: str):
    """
    Get user's shopping cart
    
    - **user_id**: User identifier
    """
    try:
        return cart_service.get_cart(user_id)
    except Exception as e:
        logger.error(f"Error getting cart for user {user_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve cart: {str(e)}"
        )


@router.post("/{user_id}/items", response_model=CartItemResponse, status_code=status.HTTP_201_CREATED)
async def add_item_to_cart(user_id: str, item: CartItemCreate):
    """
    Add item to cart
    
    - **user_id**: User identifier
    - **item**: Item details (product_id, product_name, quantity, price)
    """
    try:
        return cart_service.add_item(user_id, item)
    except Exception as e:
        logger.error(f"Error adding item to cart for user {user_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to add item to cart: {str(e)}"
        )


@router.put("/{user_id}/items/{product_id}", response_model=CartItemResponse, status_code=status.HTTP_200_OK)
async def update_cart_item(user_id: str, product_id: int, item_update: CartItemUpdate):
    """
    Update item quantity in cart
    
    - **user_id**: User identifier
    - **product_id**: Product identifier
    - **item_update**: Updated quantity
    """
    try:
        return cart_service.update_item(user_id, product_id, item_update)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"Error updating item in cart: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update item: {str(e)}"
        )


@router.delete("/{user_id}/items/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_item_from_cart(user_id: str, product_id: int):
    """
    Remove item from cart
    
    - **user_id**: User identifier
    - **product_id**: Product identifier
    """
    try:
        cart_service.remove_item(user_id, product_id)
    except Exception as e:
        logger.error(f"Error removing item from cart: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to remove item: {str(e)}"
        )


@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def clear_cart(user_id: str):
    """
    Clear all items from cart
    
    - **user_id**: User identifier
    """
    try:
        cart_service.clear_cart(user_id)
    except Exception as e:
        logger.error(f"Error clearing cart: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to clear cart: {str(e)}"
        )
