package main

import (
	"context"
	"encoding/json"
	"log"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/serverless-ecommerce/inventory-service/internal/handler"
	"github.com/serverless-ecommerce/inventory-service/internal/models"
)

var inventoryHandler *handler.InventoryHandler

func init() {
	// Initialize handler
	inventoryHandler = handler.NewInventoryHandler()
}

// Handler is the Lambda function handler
func Handler(ctx context.Context, request models.InventoryRequest) (*models.InventoryResponse, error) {
	// Log the incoming request
	reqJSON, _ := json.Marshal(request)
	log.Printf("Received inventory request: %s", string(reqJSON))

	// Check inventory
	response, err := inventoryHandler.CheckInventory(ctx, request)
	if err != nil {
		log.Printf("Error checking inventory: %v", err)
		return nil, err
	}

	// Log the response
	respJSON, _ := json.Marshal(response)
	log.Printf("Inventory response: %s", string(respJSON))

	return response, nil
}

func main() {
	lambda.Start(Handler)
}
