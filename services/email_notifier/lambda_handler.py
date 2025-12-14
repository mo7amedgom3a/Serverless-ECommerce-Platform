import json
import logging
from typing import Dict, Any

from app.email_service import EmailService
from app.config import settings

# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

# Initialize email service
email_service = EmailService()


def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Lambda handler for processing SQS messages containing order events
    """
    logger.info(f"Received event with {len(event.get('Records', []))} records")
    
    # Track failed messages for partial batch response
    batch_item_failures = []
    
    for record in event.get('Records', []):
        try:
            # Parse SNS message from SQS
            message_data = email_service.parse_sns_message(record)
            
            logger.info(f"Processing order event: {json.dumps(message_data)}")
            
            # Process the order event and send email
            email_service.process_order_event(message_data)
            
        except Exception as e:
            logger.error(f"Error processing record: {e}")
            # Add failed message to batch item failures
            batch_item_failures.append({
                "itemIdentifier": record['messageId']
            })
    
    # Return partial batch response
    return {
        "batchItemFailures": batch_item_failures
    }
