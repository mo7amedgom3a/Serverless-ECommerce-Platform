package service

import (
	"errors"

	"github.com/serverless-ecommerce/products-service/internal/dto"
	"github.com/serverless-ecommerce/products-service/internal/models"
	"github.com/serverless-ecommerce/products-service/internal/repository"
)

// InventoryService handles business logic for inventory
type InventoryService struct {
	inventoryRepo *repository.InventoryRepository
	productRepo   *repository.ProductRepository
}

// NewInventoryService creates a new inventory service
func NewInventoryService(inventoryRepo *repository.InventoryRepository, productRepo *repository.ProductRepository) *InventoryService {
	return &InventoryService{
		inventoryRepo: inventoryRepo,
		productRepo:   productRepo,
	}
}

// GetInventory retrieves inventory for a product
func (s *InventoryService) GetInventory(productID int64) (*dto.InventoryResponse, error) {
	// Check if product exists
	product, err := s.productRepo.GetByID(productID)
	if err != nil {
		return nil, err
	}
	if product == nil {
		return nil, errors.New("product not found")
	}

	inventory, err := s.inventoryRepo.GetByProductID(productID)
	if err != nil {
		return nil, err
	}
	if inventory == nil {
		return nil, errors.New("inventory not found")
	}

	return s.toInventoryResponse(inventory), nil
}

// UpdateInventory updates inventory for a product
func (s *InventoryService) UpdateInventory(productID int64, req *dto.InventoryUpdateRequest) (*dto.InventoryResponse, error) {
	// Check if product exists
	product, err := s.productRepo.GetByID(productID)
	if err != nil {
		return nil, err
	}
	if product == nil {
		return nil, errors.New("product not found")
	}

	inventory, err := s.inventoryRepo.GetByProductID(productID)
	if err != nil {
		return nil, err
	}

	// If inventory doesn't exist, create it
	if inventory == nil {
		inventory = &models.ProductInventory{
			ProductID:     productID,
			StockQuantity: 0,
		}
		if req.StockQuantity != nil {
			inventory.StockQuantity = *req.StockQuantity
		}
		if req.WarehouseLocation != nil {
			inventory.WarehouseLocation = *req.WarehouseLocation
		}
		if err := s.inventoryRepo.Create(inventory); err != nil {
			return nil, err
		}
	} else {
		// Update existing inventory
		if req.StockQuantity != nil {
			inventory.StockQuantity = *req.StockQuantity
		}
		if req.WarehouseLocation != nil {
			inventory.WarehouseLocation = *req.WarehouseLocation
		}
		if err := s.inventoryRepo.Update(inventory); err != nil {
			return nil, err
		}
	}

	return s.toInventoryResponse(inventory), nil
}

// toInventoryResponse converts an inventory model to a response DTO
func (s *InventoryService) toInventoryResponse(inventory *models.ProductInventory) *dto.InventoryResponse {
	return &dto.InventoryResponse{
		InventoryID:       inventory.InventoryID,
		ProductID:         inventory.ProductID,
		StockQuantity:     inventory.StockQuantity,
		WarehouseLocation: inventory.WarehouseLocation,
		UpdatedAt:         inventory.UpdatedAt,
	}
}
