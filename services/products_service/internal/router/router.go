package router

import (
	"github.com/gin-gonic/gin"
	"github.com/serverless-ecommerce/products-service/internal/handler"
	"github.com/serverless-ecommerce/products-service/internal/middleware"
)

// SetupRouter configures and returns the Gin router
func SetupRouter(productHandler *handler.ProductHandler, inventoryHandler *handler.InventoryHandler) *gin.Engine {
	router := gin.New()

	// Middleware
	router.Use(middleware.Logger())
	router.Use(middleware.ErrorHandler())
	router.Use(gin.Recovery())

	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "healthy"})
	})

	// Products routes
	router.GET("/products", productHandler.ListProducts)
	router.GET("/products/:id", productHandler.GetProduct)
	router.POST("/products", productHandler.CreateProduct)
	router.PUT("/products/:id", productHandler.UpdateProduct)
	router.DELETE("/products/:id", productHandler.DeleteProduct)

	// Inventory routes
	router.GET("/products/:id/inventory", inventoryHandler.GetInventory)
	router.PUT("/products/:id/inventory", inventoryHandler.UpdateInventory)

	return router
}
