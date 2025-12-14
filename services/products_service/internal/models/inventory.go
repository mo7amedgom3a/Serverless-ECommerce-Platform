package models

import "time"

// ProductInventory represents product inventory in the database
type ProductInventory struct {
	InventoryID       int64     `gorm:"primaryKey;column:inventory_id;autoIncrement" json:"inventory_id"`
	ProductID         int64     `gorm:"not null;column:product_id" json:"product_id"`
	StockQuantity     int       `gorm:"default:0;column:stock_quantity" json:"stock_quantity"`
	WarehouseLocation string    `gorm:"size:255;column:warehouse_location" json:"warehouse_location"`
	UpdatedAt         time.Time `gorm:"autoUpdateTime;column:updated_at" json:"updated_at"`

	// Relationship
	Product Product `gorm:"foreignKey:ProductID;references:ProductID" json:"product,omitempty"`
}

// TableName specifies the table name for ProductInventory model
func (ProductInventory) TableName() string {
	return "product_inventory"
}
