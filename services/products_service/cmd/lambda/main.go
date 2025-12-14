package main

import (
	"context"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	ginadapter "github.com/awslabs/aws-lambda-go-api-proxy/gin"
	"github.com/serverless-ecommerce/products-service/internal/config"
	"github.com/serverless-ecommerce/products-service/internal/database"
	"github.com/serverless-ecommerce/products-service/internal/handler"
	"github.com/serverless-ecommerce/products-service/internal/repository"
	"github.com/serverless-ecommerce/products-service/internal/router"
	"github.com/serverless-ecommerce/products-service/internal/service"
)

var ginLambda *ginadapter.GinLambda

func init() {
	// Load configuration
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	// Initialize database
	if err := database.InitDB(cfg); err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}

	// Initialize repositories
	productRepo := repository.NewProductRepository(database.GetDB())
	inventoryRepo := repository.NewInventoryRepository(database.GetDB())

	// Initialize services
	productService := service.NewProductService(productRepo)
	inventoryService := service.NewInventoryService(inventoryRepo, productRepo)

	// Initialize handlers
	productHandler := handler.NewProductHandler(productService)
	inventoryHandler := handler.NewInventoryHandler(inventoryService)

	// Setup router
	r := router.SetupRouter(productHandler, inventoryHandler)

	// Create Lambda adapter
	ginLambda = ginadapter.New(r)
}

// Handler is the Lambda function handler
func Handler(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	return ginLambda.ProxyWithContext(ctx, req)
}

func main() {
	lambda.Start(Handler)
}
