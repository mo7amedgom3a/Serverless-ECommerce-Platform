package main

import (
	"context"
	"encoding/json"
	"log"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/serverless-ecommerce/payment-service/internal/handler"
	"github.com/serverless-ecommerce/payment-service/internal/models"
)

var paymentHandler *handler.PaymentHandler

func init() {
	// Initialize handler
	paymentHandler = handler.NewPaymentHandler()
}

// Handler is the Lambda function handler
func Handler(ctx context.Context, request models.PaymentRequest) (*models.PaymentResponse, error) {
	// Log the incoming request
	reqJSON, _ := json.Marshal(request)
	log.Printf("Received payment request: %s", string(reqJSON))

	// Process payment
	response, err := paymentHandler.ProcessPayment(ctx, request)
	if err != nil {
		log.Printf("Error processing payment: %v", err)
		return nil, err
	}

	// Log the response
	respJSON, _ := json.Marshal(response)
	log.Printf("Payment response: %s", string(respJSON))

	return response, nil
}

func main() {
	lambda.Start(Handler)
}
