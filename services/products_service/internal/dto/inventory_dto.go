package dto

import "time"

// InventoryUpdateRequest represents the request to update inventory
type InventoryUpdateRequest struct {
	StockQuantity     *int    `json:"stock_quantity" binding:"omitempty,gte=0"`
	WarehouseLocation *string `json:"warehouse_location"`
}

// InventoryResponse represents the response for inventory
type InventoryResponse struct {
	InventoryID       int64     `json:"inventory_id"`
	ProductID         int64     `json:"product_id"`
	StockQuantity     int       `json:"stock_quantity"`
	WarehouseLocation string    `json:"warehouse_location"`
	UpdatedAt         time.Time `json:"updated_at"`
}
