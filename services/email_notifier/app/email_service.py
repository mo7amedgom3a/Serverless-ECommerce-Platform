import json
import logging
import boto3
from typing import Dict, Any
from jinja2 import Environment, FileSystemLoader, select_autoescape
import os

from app.config import settings

logger = logging.getLogger(__name__)


class EmailService:
    """Service for sending order notification emails"""
    
    def __init__(self):
        self.ses_client = boto3.client('ses', region_name=settings.SES_REGION)
        self.sender_email = settings.SES_SENDER_EMAIL
        
        # Setup Jinja2 template environment
        template_dir = os.path.join(os.path.dirname(__file__), 'templates')
        self.jinja_env = Environment(
            loader=FileSystemLoader(template_dir),
            autoescape=select_autoescape(['html', 'xml'])
        )
    
    def parse_sns_message(self, sqs_record: Dict[str, Any]) -> Dict[str, Any]:
        """Parse SNS message from SQS record"""
        try:
            # SQS record contains SNS message in the body
            body = json.loads(sqs_record['body'])
            
            # SNS message contains the actual event data
            if 'Message' in body:
                message = json.loads(body['Message'])
                return message
            
            return body
        except Exception as e:
            logger.error(f"Error parsing SNS message: {e}")
            raise
    
    def get_template_name(self, status: str) -> str:
        """Get email template name based on order status"""
        status_lower = status.lower()
        template_map = {
            'created': 'order_created.html',
            'pending': 'order_pending.html',
            'paid': 'order_paid.html',
            'shipped': 'order_shipped.html',
            'completed': 'order_completed.html',
        }
        return template_map.get(status_lower, 'order_created.html')
    
    def render_email_template(self, template_name: str, context: Dict[str, Any]) -> str:
        """Render email template with context data"""
        try:
            template = self.jinja_env.get_template(template_name)
            return template.render(**context)
        except Exception as e:
            logger.error(f"Error rendering template {template_name}: {e}")
            raise
    
    def send_email(self, recipient_email: str, subject: str, html_body: str):
        """Send email via AWS SES"""
        try:
            response = self.ses_client.send_email(
                Source=self.sender_email,
                Destination={
                    'ToAddresses': [recipient_email]
                },
                Message={
                    'Subject': {
                        'Data': subject,
                        'Charset': 'UTF-8'
                    },
                    'Body': {
                        'Html': {
                            'Data': html_body,
                            'Charset': 'UTF-8'
                        }
                    }
                }
            )
            logger.info(f"Email sent successfully to {recipient_email}. MessageId: {response['MessageId']}")
            return response
        except Exception as e:
            logger.error(f"Error sending email to {recipient_email}: {e}")
            raise
    
    def process_order_event(self, event_data: Dict[str, Any]):
        """Process order event and send notification email"""
        try:
            # Extract order details
            order_id = event_data.get('order_id')
            user_email = event_data.get('user_email')
            status = event_data.get('status', 'CREATED')
            order_total = event_data.get('order_total')
            items = event_data.get('items', [])
            created_at = event_data.get('created_at')
            
            if not user_email:
                logger.warning(f"No user email found for order {order_id}")
                return
            
            # Get appropriate template
            template_name = self.get_template_name(status)
            
            # Prepare template context
            context = {
                'order_id': order_id,
                'status': status,
                'order_total': order_total,
                'items': items,
                'created_at': created_at,
                'user_email': user_email
            }
            
            # Render email
            html_body = self.render_email_template(template_name, context)
            
            # Prepare subject
            subject = f"Order #{order_id} - {status.title()}"
            
            # Send email
            self.send_email(user_email, subject, html_body)
            
            logger.info(f"Successfully processed order event for order {order_id}")
            
        except Exception as e:
            logger.error(f"Error processing order event: {e}")
            raise
