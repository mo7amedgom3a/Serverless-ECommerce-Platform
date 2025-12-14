package service

import (
	"errors"
	"fmt"

	"github.com/serverless-ecommerce/products-service/internal/dto"
	"github.com/serverless-ecommerce/products-service/internal/models"
	"github.com/serverless-ecommerce/products-service/internal/repository"
)

// ProductService handles business logic for products
type ProductService struct {
	productRepo *repository.ProductRepository
}

// NewProductService creates a new product service
func NewProductService(productRepo *repository.ProductRepository) *ProductService {
	return &ProductService{productRepo: productRepo}
}

// GetProduct retrieves a product by ID
func (s *ProductService) GetProduct(id int64) (*dto.ProductResponse, error) {
	product, err := s.productRepo.GetByID(id)
	if err != nil {
		return nil, err
	}
	if product == nil {
		return nil, errors.New("product not found")
	}
	return s.toProductResponse(product), nil
}

// ListProducts retrieves products with pagination
func (s *ProductService) ListProducts(page, pageSize int) (*dto.ProductListResponse, error) {
	offset := (page - 1) * pageSize
	products, total, err := s.productRepo.List(offset, pageSize)
	if err != nil {
		return nil, err
	}

	productResponses := make([]dto.ProductResponse, len(products))
	for i, product := range products {
		productResponses[i] = *s.toProductResponse(&product)
	}

	return &dto.ProductListResponse{
		Products: productResponses,
		Total:    total,
		Page:     page,
		PageSize: pageSize,
	}, nil
}

// CreateProduct creates a new product
func (s *ProductService) CreateProduct(req *dto.ProductCreateRequest) (*dto.ProductResponse, error) {
	// Check if SKU already exists
	existing, err := s.productRepo.GetBySKU(req.SKU)
	if err != nil {
		return nil, err
	}
	if existing != nil {
		return nil, fmt.Errorf("product with SKU %s already exists", req.SKU)
	}

	product := &models.Product{
		SKU:         req.SKU,
		Name:        req.Name,
		Description: req.Description,
		Price:       req.Price,
	}

	if err := s.productRepo.Create(product); err != nil {
		return nil, err
	}

	return s.toProductResponse(product), nil
}

// UpdateProduct updates an existing product
func (s *ProductService) UpdateProduct(id int64, req *dto.ProductUpdateRequest) (*dto.ProductResponse, error) {
	product, err := s.productRepo.GetByID(id)
	if err != nil {
		return nil, err
	}
	if product == nil {
		return nil, errors.New("product not found")
	}

	// Update fields if provided
	if req.Name != nil {
		product.Name = *req.Name
	}
	if req.Description != nil {
		product.Description = *req.Description
	}
	if req.Price != nil {
		product.Price = *req.Price
	}

	if err := s.productRepo.Update(product); err != nil {
		return nil, err
	}

	return s.toProductResponse(product), nil
}

// DeleteProduct deletes a product
func (s *ProductService) DeleteProduct(id int64) error {
	return s.productRepo.Delete(id)
}

// toProductResponse converts a product model to a response DTO
func (s *ProductService) toProductResponse(product *models.Product) *dto.ProductResponse {
	return &dto.ProductResponse{
		ProductID:   product.ProductID,
		SKU:         product.SKU,
		Name:        product.Name,
		Description: product.Description,
		Price:       product.Price,
		CreatedAt:   product.CreatedAt,
	}
}
