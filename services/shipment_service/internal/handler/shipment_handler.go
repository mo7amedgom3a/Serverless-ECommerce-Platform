package handler

import (
	"context"
	"fmt"
	"math/rand"
	"time"

	"github.com/serverless-ecommerce/shipment-service/internal/models"
)

// ShipmentHandler handles shipment creation logic
type ShipmentHandler struct{}

// NewShipmentHandler creates a new shipment handler
func NewShipmentHandler() *ShipmentHandler {
	return &ShipmentHandler{}
}

// CreateShipment creates a shipment with mock logic
func (h *ShipmentHandler) CreateShipment(ctx context.Context, req models.ShipmentRequest) (*models.ShipmentResponse, error) {
	// Generate mock shipment data
	trackingNumber := fmt.Sprintf("TRACK-%s-%d", time.Now().Format("20060102"), rand.Intn(90000)+10000)
	shipmentID := fmt.Sprintf("SHIP-%d", rand.Intn(900000)+100000)

	// Mock carrier selection
	carriers := []string{"FedEx", "UPS", "DHL", "USPS"}
	carrier := carriers[rand.Intn(len(carriers))]

	// Estimated delivery (3-7 days from now)
	deliveryDays := rand.Intn(5) + 3
	estimatedDelivery := time.Now().AddDate(0, 0, deliveryDays).Format("2006-01-02")

	response := &models.ShipmentResponse{
		OrderID:           req.OrderID,
		ProductID:         req.ProductID,
		Quantity:          req.Quantity,
		ShipmentID:        shipmentID,
		TrackingNumber:    trackingNumber,
		Carrier:           carrier,
		EstimatedDelivery: estimatedDelivery,
		Status:            "CREATED",
		Message:           "Shipment created successfully",
		Timestamp:         time.Now(),
		Amount:            req.Amount,
		TransactionID:     req.TransactionID,
	}

	return response, nil
}
