import os
import json
import logging
import boto3
from typing import Dict, Any, Optional
from decimal import Decimal

from app.config import settings

logger = logging.getLogger(__name__)


class DecimalEncoder(json.JSONEncoder):
    """Custom JSON encoder for Decimal types"""
    def default(self, obj):
        if isinstance(obj, Decimal):
            return str(obj)
        return super(DecimalEncoder, self).default(obj)


class NotificationService:
    """Service for publishing order events to SNS"""
    
    def __init__(self):
        self.sns_client = boto3.client('sns', region_name=settings.AWS_REGION)
        self.topic_arn = settings.SNS_TOPIC_ARN
    
    def publish_order_event(
        self,
        order_id: int,
        user_id: int,
        user_email: str,
        status: str,
        order_total: Decimal,
        items: list,
        created_at: str,
        event_type: Optional[str] = None
    ):
        """
        Publish order event to SNS topic
        
        Args:
            order_id: Order ID
            user_id: User ID
            user_email: User email address
            status: Order status (CREATED, PENDING, PAID, SHIPPED, COMPLETED)
            order_total: Total order amount
            items: List of order items
            created_at: Order creation timestamp
            event_type: Optional event type override
        """
        try:
            if not self.topic_arn:
                logger.warning("SNS topic ARN not configured, skipping notification")
                return
            
            # Determine event type from status if not provided
            if not event_type:
                event_type = f"order.{status.lower()}"
            
            # Prepare message payload
            message = {
                "order_id": order_id,
                "user_id": user_id,
                "user_email": user_email,
                "status": status,
                "order_total": str(order_total),
                "items": items,
                "created_at": created_at,
                "event_type": event_type
            }
            
            # Publish to SNS
            response = self.sns_client.publish(
                TopicArn=self.topic_arn,
                Message=json.dumps(message, cls=DecimalEncoder),
                Subject=f"Order {order_id} - {status}",
                MessageAttributes={
                    'event_type': {
                        'DataType': 'String',
                        'StringValue': event_type
                    },
                    'order_id': {
                        'DataType': 'Number',
                        'StringValue': str(order_id)
                    },
                    'status': {
                        'DataType': 'String',
                        'StringValue': status
                    }
                }
            )
            
            logger.info(f"Published order event to SNS. MessageId: {response['MessageId']}")
            return response
            
        except Exception as e:
            logger.error(f"Error publishing order event to SNS: {e}")
            # Don't raise exception to avoid breaking order creation/update
            # Notifications are non-critical
