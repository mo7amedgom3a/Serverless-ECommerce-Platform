package service

import (
	"context"
	"errors"
	"fmt"
	"log"

	"github.com/redis/go-redis/v9"
	"github.com/serverless-ecommerce/products-service/internal/cache"
	"github.com/serverless-ecommerce/products-service/internal/dto"
	"github.com/serverless-ecommerce/products-service/internal/models"
	"github.com/serverless-ecommerce/products-service/internal/repository"
)

// ProductService handles business logic for products
type ProductService struct {
	productRepo  *repository.ProductRepository
	cacheService *cache.CacheService
}

// NewProductService creates a new product service
func NewProductService(productRepo *repository.ProductRepository, cacheService *cache.CacheService) *ProductService {
	return &ProductService{
		productRepo:  productRepo,
		cacheService: cacheService,
	}
}

// GetProduct retrieves a product by ID with Lazy Loading
func (s *ProductService) GetProduct(id int64) (*dto.ProductResponse, error) {
	ctx := context.Background()

	// 1. Try cache first (Lazy Loading)
	cached, err := s.cacheService.GetProduct(ctx, id)
	if err == nil && cached != nil {
		return cached, nil // Cache hit
	}
	if err != nil && err != redis.Nil {
		log.Printf("Cache error for product:%d - %v", id, err)
	}

	// 2. Cache miss - fetch from database
	log.Printf("Cache MISS: product:%d - fetching from DB", id)
	product, err := s.productRepo.GetByID(id)
	if err != nil {
		return nil, err
	}
	if product == nil {
		return nil, errors.New("product not found")
	}

	// 3. Store in cache for next time
	response := s.toProductResponse(product)
	if err := s.cacheService.SetProduct(ctx, response); err != nil {
		log.Printf("Failed to cache product:%d - %v", id, err)
	}

	return response, nil
}

// ListProducts retrieves products with pagination and Lazy Loading
func (s *ProductService) ListProducts(page, pageSize int) (*dto.ProductListResponse, error) {
	ctx := context.Background()

	// 1. Try cache first
	cached, err := s.cacheService.GetProductList(ctx, page, pageSize)
	if err == nil && cached != nil {
		return cached, nil // Cache hit
	}
	if err != nil && err != redis.Nil {
		log.Printf("Cache error for products list - %v", err)
	}

	// 2. Cache miss - fetch from database
	log.Printf("Cache MISS: products:list:%d:%d - fetching from DB", page, pageSize)
	offset := (page - 1) * pageSize
	products, total, err := s.productRepo.List(offset, pageSize)
	if err != nil {
		return nil, err
	}

	productResponses := make([]dto.ProductResponse, len(products))
	for i, product := range products {
		productResponses[i] = *s.toProductResponse(&product)
	}

	response := &dto.ProductListResponse{
		Products: productResponses,
		Total:    total,
		Page:     page,
		PageSize: pageSize,
	}

	// 3. Store in cache
	if err := s.cacheService.SetProductList(ctx, page, pageSize, response); err != nil {
		log.Printf("Failed to cache product list - %v", err)
	}

	return response, nil
}

// CreateProduct creates a new product with cache invalidation
func (s *ProductService) CreateProduct(req *dto.ProductCreateRequest) (*dto.ProductResponse, error) {
	ctx := context.Background()

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

	// Invalidate product lists cache
	if err := s.cacheService.InvalidateProductLists(ctx); err != nil {
		log.Printf("Failed to invalidate product lists cache - %v", err)
	}

	return s.toProductResponse(product), nil
}

// UpdateProduct updates an existing product with cache invalidation
func (s *ProductService) UpdateProduct(id int64, req *dto.ProductUpdateRequest) (*dto.ProductResponse, error) {
	ctx := context.Background()

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

	// Invalidate specific product cache
	if err := s.cacheService.DeleteProduct(ctx, id); err != nil {
		log.Printf("Failed to invalidate product:%d cache - %v", id, err)
	}

	// Invalidate product lists cache
	if err := s.cacheService.InvalidateProductLists(ctx); err != nil {
		log.Printf("Failed to invalidate product lists cache - %v", err)
	}

	return s.toProductResponse(product), nil
}

// DeleteProduct deletes a product with cache invalidation
func (s *ProductService) DeleteProduct(id int64) error {
	ctx := context.Background()

	if err := s.productRepo.Delete(id); err != nil {
		return err
	}

	// Invalidate specific product cache
	if err := s.cacheService.DeleteProduct(ctx, id); err != nil {
		log.Printf("Failed to invalidate product:%d cache - %v", id, err)
	}

	// Invalidate product lists cache
	if err := s.cacheService.InvalidateProductLists(ctx); err != nil {
		log.Printf("Failed to invalidate product lists cache - %v", err)
	}

	return nil
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
