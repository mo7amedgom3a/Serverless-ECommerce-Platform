package models

import "time"

// Product represents a product in the database
type Product struct {
	ProductID   int64     `gorm:"primaryKey;column:product_id;autoIncrement" json:"product_id"`
	SKU         string    `gorm:"uniqueIndex;not null;size:100" json:"sku"`
	Name        string    `gorm:"not null;size:255" json:"name"`
	Description string    `gorm:"type:text" json:"description"`
	Price       float64   `gorm:"type:decimal(10,2);not null" json:"price"`
	CreatedAt   time.Time `gorm:"autoCreateTime;column:created_at" json:"created_at"`
}

// TableName specifies the table name for Product model
func (Product) TableName() string {
	return "products"
}
