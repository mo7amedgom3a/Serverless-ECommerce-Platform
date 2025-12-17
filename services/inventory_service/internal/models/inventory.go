package models

import "time"

// InventoryRequest represents the input to the inventory Lambda
type InventoryRequest struct {
	OrderID       string  `json:"orderId"`
	ProductID     string  `json:"productId"`
	Quantity      int     `json:"quantity"`
	Amount        float64 `json:"amount,omitempty"`
	PaymentStatus string  `json:"paymentStatus,omitempty"`
	TransactionID string  `json:"transactionId,omitempty"`
}

// InventoryResponse represents the output from the inventory Lambda
type InventoryResponse struct {
	OrderID        string    `json:"orderId"`
	ProductID      string    `json:"productId"`
	Quantity       int       `json:"quantity"`
	InStock        bool      `json:"inStock"`
	AvailableStock int       `json:"availableStock"`
	Message        string    `json:"message"`
	Timestamp      time.Time `json:"timestamp"`
	Amount         float64   `json:"amount,omitempty"`
	PaymentStatus  string    `json:"paymentStatus,omitempty"`
	TransactionID  string    `json:"transactionId,omitempty"`
}
