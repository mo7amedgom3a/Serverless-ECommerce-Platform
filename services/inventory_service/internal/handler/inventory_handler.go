package handler

import (
	"context"
	"fmt"
	"math/rand"
	"time"

	"github.com/serverless-ecommerce/inventory-service/internal/models"
)

// InventoryHandler handles inventory checking logic
type InventoryHandler struct{}

// NewInventoryHandler creates a new inventory handler
func NewInventoryHandler() *InventoryHandler {
	return &InventoryHandler{}
}

// CheckInventory checks inventory availability with mock logic
func (h *InventoryHandler) CheckInventory(ctx context.Context, req models.InventoryRequest) (*models.InventoryResponse, error) {
	// Mock inventory data - random stock between 0 and 100
	mockStock := rand.Intn(101)

	// Determine if item is in stock
	inStock := mockStock >= req.Quantity

	var message string
	if inStock {
		message = "Sufficient stock available"
	} else {
		message = fmt.Sprintf("Insufficient stock available. Requested: %d, Available: %d", req.Quantity, mockStock)
	}

	response := &models.InventoryResponse{
		OrderID:        req.OrderID,
		ProductID:      req.ProductID,
		Quantity:       req.Quantity,
		InStock:        inStock,
		AvailableStock: mockStock,
		Message:        message,
		Timestamp:      time.Now(),
		Amount:         req.Amount,
		PaymentStatus:  req.PaymentStatus,
		TransactionID:  req.TransactionID,
	}

	return response, nil
}
