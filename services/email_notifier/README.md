# Email Notifier Service

Event-driven email notification service that processes SQS messages and sends emails via AWS SES.

## 📋 Overview

The Email Notifier Service is a serverless microservice that listens to SQS queue messages and sends transactional emails using AWS SES. It operates asynchronously, triggered by order events published to SNS.

## 🏗️ Architecture

```
SNS Topic → SQS Queue → Lambda (Email Notifier) → SES
                ↓
           Dead Letter Queue
```

### Technology Stack

- **Language**: Python 3.11
- **Framework**: None (lightweight)
- **Messaging**: AWS SQS
- **Email**: AWS SES
- **Deployment**: AWS Lambda (Container)
- **Trigger**: SQS Event

## 📁 Project Structure

```
email_notifier/
├── app/
│   ├── email_service.py    # Email sending logic
│   ├── templates.py         # Email templates
│   └── config.py            # Configuration
├── lambda_handler.py        # Lambda entry point
├── requirements.txt         # Dependencies
├── Dockerfile               # Lambda container
└── env.example              # Environment template
```

## 🚀 Features

### Email Notifications

- ✅ Order confirmation emails
- ✅ Order status updates
- ✅ Shipping notifications
- ✅ HTML email templates
- ✅ Dynamic content rendering

### SQS Integration

- ✅ Event-driven processing
- ✅ Batch message handling
- ✅ Automatic retries
- ✅ Dead letter queue for failures
- ✅ Message visibility timeout

### SES Integration

- ✅ Transactional email delivery
- ✅ Email template rendering
- ✅ Sender verification
- ✅ Bounce/complaint handling

### AWS Integration

- **SQS**: Message queue consumption
- **SNS**: Event source
- **SES**: Email delivery
- **Lambda**: Serverless execution
- **CloudWatch**: Logging and monitoring

## 🔄 Event Flow

```
1. Order Service creates order
2. Publishes event to SNS topic
3. SNS forwards to SQS queue
4. SQS triggers Email Notifier Lambda
5. Lambda processes message
6. Renders email template
7. Sends email via SES
8. Deletes message from queue
```

## 📬 Message Format

### SQS Message Structure

```json
{
  "Records": [
    {
      "messageId": "...",
      "body": "{\"Message\": \"{\\\"event_type\\\":\\\"order_created\\\",\\\"order_id\\\":1,\\\"user_id\\\":1,\\\"order_total\\\":109.97}\"}"
    }
  ]
}
```

### Event Types

| Event Type      | Email Template        | Recipient |
| --------------- | --------------------- | --------- |
| `order_created` | Order Confirmation    | Customer  |
| `order_updated` | Status Update         | Customer  |
| `order_shipped` | Shipping Notification | Customer  |

## 📧 Email Templates

### Order Confirmation

```html
Subject: Order Confirmation - Order #{order_id} Dear Customer, Thank you for
your order! Order Details: - Order ID: {order_id} - Total: ${order_total} -
Status: {status} We'll send you another email when your order ships. Best
regards, E-Commerce Team
```

### Order Shipped

```html
Subject: Your Order Has Shipped - Order #{order_id} Dear Customer, Great news!
Your order #{order_id} has been shipped. You can track your package using the
tracking number provided. Best regards, E-Commerce Team
```

## ⚙️ Configuration

### Environment Variables

| Variable           | Description           | Default     |
| ------------------ | --------------------- | ----------- |
| `ENVIRONMENT`      | Environment name      | `dev`       |
| `LOG_LEVEL`        | Logging level         | `INFO`      |
| `AWS_REGION`       | AWS region            | `us-east-1` |
| `SES_SENDER_EMAIL` | Verified sender email | -           |

### SES Configuration

**Sender Email**: Must be verified in SES

```bash
# Verify email address
aws ses verify-email-identity --email-address noreply@example.com

# Check verification status
aws ses get-identity-verification-attributes \
  --identities noreply@example.com
```

### SQS Configuration

- **Visibility Timeout**: 60 seconds
- **Max Receive Count**: 3
- **Dead Letter Queue**: Enabled
- **Batch Size**: 10 messages

## 🚀 Lambda Handler

```python
def lambda_handler(event, context):
    """
    Process SQS messages and send emails
    """
    for record in event['Records']:
        try:
            # Parse message
            message = json.loads(record['body'])
            sns_message = json.loads(message['Message'])

            # Extract event data
            event_type = sns_message['event_type']
            order_id = sns_message['order_id']

            # Send email
            send_email(event_type, sns_message)

            logger.info(f"Email sent for {event_type}: order_id={order_id}")

        except Exception as e:
            logger.error(f"Failed to process message: {e}")
            raise  # Trigger retry or DLQ

    return {'statusCode': 200}
```

## 📦 Deployment

### Build and Deploy

```bash
# Build Docker image
docker build -t email-notifier:latest .

# Tag for ECR
docker tag email-notifier:latest \
  {account}.dkr.ecr.{region}.amazonaws.com/email-notifier:latest

# Push to ECR
docker push {account}.dkr.ecr.{region}.amazonaws.com/email-notifier:latest

# Deploy with Terraform
cd ../../terraform
terraform apply -var-file=dev.tfvars
```

### Terraform Configuration

```hcl
module "email_notifier" {
  source = "./modules/lambdas/email_notifier"

  sqs_queue_arn          = module.sns_sqs.sqs_queue_arn
  ses_sender_email       = "noreply@example.com"
  sqs_consume_policy_arn = module.iam.sqs_consume_policy_arn
  ses_send_email_policy_arn = module.iam.ses_send_email_policy_arn
}
```

## 🔐 Security

### IAM Permissions

Required permissions:

- `sqs:ReceiveMessage` - Read from queue
- `sqs:DeleteMessage` - Delete processed messages
- `sqs:GetQueueAttributes` - Queue metadata
- `ses:SendEmail` - Send emails
- `ses:SendRawEmail` - Send formatted emails
- `logs:CreateLogGroup` - CloudWatch logging

### Email Security

- **SPF**: Configure SPF records
- **DKIM**: Enable DKIM signing
- **DMARC**: Set up DMARC policy
- **Bounce Handling**: Monitor bounces
- **Complaint Handling**: Track complaints

## 📊 Monitoring

### CloudWatch Metrics

- **Lambda**:

  - Invocations
  - Duration
  - Errors
  - Throttles

- **SQS**:

  - Messages received
  - Messages deleted
  - Messages in DLQ
  - Age of oldest message

- **SES**:
  - Emails sent
  - Bounces
  - Complaints
  - Delivery rate

### CloudWatch Logs

```
INFO: Processing 5 messages from SQS
INFO: Event type: order_created, order_id: 1
INFO: Sending email to: customer@example.com
INFO: Email sent successfully via SES
INFO: Message deleted from queue
```

### Alarms

```hcl
# DLQ alarm
resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "email-notifier-dlq-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Average"
  threshold           = "0"
}
```

## 🧪 Testing

### Local Testing

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
export SES_SENDER_EMAIL=noreply@example.com

# Test email sending
python -c "from app.email_service import send_email; \
  send_email('order_created', {'order_id': 1, 'user_id': 1})"
```

### Integration Testing

```bash
# Send test message to SQS
aws sqs send-message \
  --queue-url https://sqs.{region}.amazonaws.com/{account}/order-events \
  --message-body '{"event_type":"order_created","order_id":1}'

# Check CloudWatch logs
aws logs tail /aws/lambda/email-notifier --follow
```

## 🔧 Troubleshooting

### Email Not Sent

1. **Check SES verification**:

   ```bash
   aws ses get-identity-verification-attributes \
     --identities noreply@example.com
   ```

2. **Check SES sending limits**:

   ```bash
   aws ses get-send-quota
   ```

3. **Review Lambda logs**:
   ```bash
   aws logs tail /aws/lambda/email-notifier --since 1h
   ```

### Messages in DLQ

1. **View DLQ messages**:

   ```bash
   aws sqs receive-message \
     --queue-url https://sqs.{region}.amazonaws.com/{account}/order-events-dlq
   ```

2. **Analyze failure patterns**
3. **Fix root cause**
4. **Redrive messages** from DLQ

### High Error Rate

- Check SES bounce rate
- Verify email templates
- Review message format
- Check IAM permissions

## 📈 Performance

- **Processing Time**: ~200ms per message
- **Batch Size**: 10 messages
- **Concurrent Executions**: Auto-scaling
- **Email Delivery**: ~1-2 seconds

## 🔄 Future Enhancements

- [ ] Email template management
- [ ] Multi-language support
- [ ] Email scheduling
- [ ] Attachment support
- [ ] Email tracking (opens/clicks)
- [ ] Unsubscribe management

## 📚 Related Documentation

- [Main Services README](../README.md)
- [Orders Service](../orders_service/README.md)
- [SNS/SQS Terraform Module](../../terraform/modules/sns_sqs/)
- [Email Notifier Lambda Module](../../terraform/modules/lambdas/email_notifier/)

## 📄 License

Part of the Serverless E-Commerce Platform.
