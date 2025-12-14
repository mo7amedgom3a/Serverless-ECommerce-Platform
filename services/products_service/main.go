package main

import (
	"log"

	"github.com/serverless-ecommerce/products-service/internal/config"
	"github.com/serverless-ecommerce/products-service/internal/database"
	"github.com/serverless-ecommerce/products-service/internal/handler"
	"github.com/serverless-ecommerce/products-service/internal/repository"
	"github.com/serverless-ecommerce/products-service/internal/router"
	"github.com/serverless-ecommerce/products-service/internal/service"
)

func main() {
	// Load configuration
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	// Initialize database
	if err := database.InitDB(cfg); err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer database.CloseDB()

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

	// Start server
	log.Println("Starting server on :8080")
	if err := r.Run(":8080"); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
