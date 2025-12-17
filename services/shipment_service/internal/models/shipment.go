package models

import "time"

// ShipmentRequest represents the input to the shipment Lambda
type ShipmentRequest struct {
	OrderID       string  `json:"orderId"`
	ProductID     string  `json:"productId"`
	Quantity      int     `json:"quantity"`
	Amount        float64 `json:"amount,omitempty"`
	TransactionID string  `json:"transactionId,omitempty"`
	InStock       bool    `json:"inStock,omitempty"`
}

// ShipmentResponse represents the output from the shipment Lambda
type ShipmentResponse struct {
	OrderID           string    `json:"orderId"`
	ProductID         string    `json:"productId"`
	Quantity          int       `json:"quantity"`
	ShipmentID        string    `json:"shipmentId"`
	TrackingNumber    string    `json:"trackingNumber"`
	Carrier           string    `json:"carrier"`
	EstimatedDelivery string    `json:"estimatedDelivery"`
	Status            string    `json:"status"`
	Message           string    `json:"message"`
	Timestamp         time.Time `json:"timestamp"`
	Amount            float64   `json:"amount,omitempty"`
	TransactionID     string    `json:"transactionId,omitempty"`
}
