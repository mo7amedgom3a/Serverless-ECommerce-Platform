package main

import (
	"context"
	"encoding/json"
	"log"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/serverless-ecommerce/shipment-service/internal/handler"
	"github.com/serverless-ecommerce/shipment-service/internal/models"
)

var shipmentHandler *handler.ShipmentHandler

func init() {
	// Initialize handler
	shipmentHandler = handler.NewShipmentHandler()
}

// Handler is the Lambda function handler
func Handler(ctx context.Context, request models.ShipmentRequest) (*models.ShipmentResponse, error) {
	// Log the incoming request
	reqJSON, _ := json.Marshal(request)
	log.Printf("Received shipment request: %s", string(reqJSON))

	// Create shipment
	response, err := shipmentHandler.CreateShipment(ctx, request)
	if err != nil {
		log.Printf("Error creating shipment: %v", err)
		return nil, err
	}

	// Log the response
	respJSON, _ := json.Marshal(response)
	log.Printf("Shipment response: %s", string(respJSON))

	return response, nil
}

func main() {
	lambda.Start(Handler)
}
