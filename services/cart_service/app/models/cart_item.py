from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Optional


@dataclass
class CartItem:
    """Cart item model for DynamoDB"""
    
    user_id: str
    item_id: str
    product_id: int
    product_name: str
    quantity: int
    price: float
    added_at: str
    ttl: Optional[int] = None
    
    @staticmethod
    def create_item_id(product_id: int) -> str:
        """Create item_id from product_id"""
        return f"ITEM#{product_id}"
    
    @staticmethod
    def extract_product_id(item_id: str) -> int:
        """Extract product_id from item_id"""
        return int(item_id.replace("ITEM#", ""))
    
    @staticmethod
    def calculate_ttl(days: int = 30) -> int:
        """Calculate TTL timestamp (30 days from now)"""
        expiration = datetime.utcnow() + timedelta(days=days)
        return int(expiration.timestamp())
    
    def to_dynamodb_item(self) -> dict:
        """Convert to DynamoDB item format"""
        return {
            'user_id': {'S': self.user_id},
            'item_id': {'S': self.item_id},
            'product_id': {'N': str(self.product_id)},
            'product_name': {'S': self.product_name},
            'quantity': {'N': str(self.quantity)},
            'price': {'N': str(self.price)},
            'added_at': {'S': self.added_at},
            'ttl': {'N': str(self.ttl)} if self.ttl else {'NULL': True}
        }
    
    @staticmethod
    def from_dynamodb_item(item: dict) -> 'CartItem':
        """Create CartItem from DynamoDB item"""
        return CartItem(
            user_id=item['user_id']['S'],
            item_id=item['item_id']['S'],
            product_id=int(item['product_id']['N']),
            product_name=item['product_name']['S'],
            quantity=int(item['quantity']['N']),
            price=float(item['price']['N']),
            added_at=item['added_at']['S'],
            ttl=int(item['ttl']['N']) if 'ttl' in item and 'N' in item['ttl'] else None
        )
