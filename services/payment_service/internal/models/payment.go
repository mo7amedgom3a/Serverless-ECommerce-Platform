package models

import "time"

// PaymentRequest represents the input to the payment Lambda
type PaymentRequest struct {
	OrderID       string  `json:"orderId"`
	Amount        float64 `json:"amount"`
	PaymentMethod string  `json:"paymentMethod"`
	ProductID     string  `json:"productId,omitempty"`
	Quantity      int     `json:"quantity,omitempty"`
}

// PaymentResponse represents the output from the payment Lambda
type PaymentResponse struct {
	OrderID       string    `json:"orderId"`
	Amount        float64   `json:"amount"`
	PaymentMethod string    `json:"paymentMethod"`
	PaymentStatus string    `json:"paymentStatus"`
	TransactionID string    `json:"transactionId,omitempty"`
	Message       string    `json:"message"`
	Timestamp     time.Time `json:"timestamp"`
	ProductID     string    `json:"productId,omitempty"`
	Quantity      int       `json:"quantity,omitempty"`
}
