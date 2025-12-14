package repository

import (
	"errors"

	"github.com/serverless-ecommerce/products-service/internal/models"
	"gorm.io/gorm"
)

// InventoryRepository handles database operations for inventory
type InventoryRepository struct {
	db *gorm.DB
}

// NewInventoryRepository creates a new inventory repository
func NewInventoryRepository(db *gorm.DB) *InventoryRepository {
	return &InventoryRepository{db: db}
}

// GetByProductID retrieves inventory by product ID
func (r *InventoryRepository) GetByProductID(productID int64) (*models.ProductInventory, error) {
	var inventory models.ProductInventory
	result := r.db.Where("product_id = ?", productID).First(&inventory)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, result.Error
	}
	return &inventory, nil
}

// Create creates a new inventory record
func (r *InventoryRepository) Create(inventory *models.ProductInventory) error {
	return r.db.Create(inventory).Error
}

// Update updates an existing inventory record
func (r *InventoryRepository) Update(inventory *models.ProductInventory) error {
	return r.db.Save(inventory).Error
}
