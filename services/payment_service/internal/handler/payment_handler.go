package handler

import (
	"context"
	"fmt"
	"math/rand"
	"time"

	"github.com/serverless-ecommerce/payment-service/internal/models"
)

// PaymentHandler handles payment processing logic
type PaymentHandler struct{}

// NewPaymentHandler creates a new payment handler
func NewPaymentHandler() *PaymentHandler {
	return &PaymentHandler{}
}

// ProcessPayment processes a payment request with mock logic
func (h *PaymentHandler) ProcessPayment(ctx context.Context, req models.PaymentRequest) (*models.PaymentResponse, error) {
	// Mock payment processing logic
	// For demo: amounts less than 1000 succeed, others fail
	var paymentStatus string
	var transactionID string
	var message string

	if req.Amount < 1000 {
		paymentStatus = "SUCCESS"
		transactionID = fmt.Sprintf("TXN-%s-%d", time.Now().Format("20060102150405"), rand.Intn(9000)+1000)
		message = "Payment processed successfully"
	} else {
		paymentStatus = "FAILED"
		transactionID = ""
		message = "Payment declined - amount exceeds limit"
	}

	response := &models.PaymentResponse{
		OrderID:       req.OrderID,
		Amount:        req.Amount,
		PaymentMethod: req.PaymentMethod,
		PaymentStatus: paymentStatus,
		TransactionID: transactionID,
		Message:       message,
		Timestamp:     time.Now(),
		ProductID:     req.ProductID,
		Quantity:      req.Quantity,
	}

	return response, nil
}
