import boto3
import logging
from datetime import datetime
from typing import List, Optional
from botocore.exceptions import ClientError

from app.models.cart_item import CartItem
from app.config import config

logger = logging.getLogger(__name__)


class CartRepository:
    """Repository for cart operations with DynamoDB"""
    
    def __init__(self):
        endpoint_url = config.get_dynamodb_endpoint()
        self.dynamodb = boto3.client(
            'dynamodb',
            region_name=config.aws_region,
            endpoint_url=endpoint_url
        )
        self.table_name = config.dynamodb_table_name
    
    def get_user_cart(self, user_id: str) -> List[CartItem]:
        """Get all items in user's cart"""
        try:
            response = self.dynamodb.query(
                TableName=self.table_name,
                KeyConditionExpression='user_id = :user_id',
                ExpressionAttributeValues={
                    ':user_id': {'S': user_id}
                }
            )
            
            items = []
            for item in response.get('Items', []):
                items.append(CartItem.from_dynamodb_item(item))
            
            logger.info(f"Retrieved {len(items)} items for user {user_id}")
            return items
            
        except ClientError as e:
            logger.error(f"Error getting cart for user {user_id}: {e}")
            raise
    
    def add_item(self, cart_item: CartItem) -> CartItem:
        """Add or update item in cart"""
        try:
            # Set TTL if not already set
            if not cart_item.ttl:
                cart_item.ttl = CartItem.calculate_ttl(config.cart_ttl_days)
            
            # Set added_at if not set
            if not cart_item.added_at:
                cart_item.added_at = datetime.utcnow().isoformat()
            
            self.dynamodb.put_item(
                TableName=self.table_name,
                Item={
                    'user_id': {'S': cart_item.user_id},
                    'item_id': {'S': cart_item.item_id},
                    'product_id': {'N': str(cart_item.product_id)},
                    'product_name': {'S': cart_item.product_name},
                    'quantity': {'N': str(cart_item.quantity)},
                    'price': {'N': str(cart_item.price)},
                    'added_at': {'S': cart_item.added_at},
                    'ttl': {'N': str(cart_item.ttl)}
                }
            )
            
            logger.info(f"Added item {cart_item.item_id} to cart for user {cart_item.user_id}")
            return cart_item
            
        except ClientError as e:
            logger.error(f"Error adding item to cart: {e}")
            raise
    
    def update_quantity(self, user_id: str, product_id: int, quantity: int) -> Optional[CartItem]:
        """Update item quantity"""
        try:
            item_id = CartItem.create_item_id(product_id)
            
            response = self.dynamodb.update_item(
                TableName=self.table_name,
                Key={
                    'user_id': {'S': user_id},
                    'item_id': {'S': item_id}
                },
                UpdateExpression='SET quantity = :quantity',
                ExpressionAttributeValues={
                    ':quantity': {'N': str(quantity)}
                },
                ReturnValues='ALL_NEW'
            )
            
            if 'Attributes' in response:
                updated_item = CartItem.from_dynamodb_item(response['Attributes'])
                logger.info(f"Updated quantity for item {item_id} to {quantity}")
                return updated_item
            
            return None
            
        except ClientError as e:
            logger.error(f"Error updating item quantity: {e}")
            raise
    
    def remove_item(self, user_id: str, product_id: int) -> None:
        """Remove item from cart"""
        try:
            item_id = CartItem.create_item_id(product_id)
            
            self.dynamodb.delete_item(
                TableName=self.table_name,
                Key={
                    'user_id': {'S': user_id},
                    'item_id': {'S': item_id}
                }
            )
            
            logger.info(f"Removed item {item_id} from cart for user {user_id}")
            
        except ClientError as e:
            logger.error(f"Error removing item from cart: {e}")
            raise
    
    def clear_cart(self, user_id: str) -> None:
        """Remove all items from user's cart"""
        try:
            # First, get all items
            items = self.get_user_cart(user_id)
            
            if not items:
                logger.info(f"Cart already empty for user {user_id}")
                return
            
            # Delete each item
            for item in items:
                self.dynamodb.delete_item(
                    TableName=self.table_name,
                    Key={
                        'user_id': {'S': user_id},
                        'item_id': {'S': item.item_id}
                    }
                )
            
            logger.info(f"Cleared {len(items)} items from cart for user {user_id}")
            
        except ClientError as e:
            logger.error(f"Error clearing cart: {e}")
            raise
