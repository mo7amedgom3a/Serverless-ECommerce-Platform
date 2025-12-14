package cache

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/redis/go-redis/v9"
	"github.com/serverless-ecommerce/products-service/internal/dto"
)

// CacheService handles caching operations with Lazy Loading pattern
type CacheService struct {
	redis *RedisClient
	ttl   time.Duration
}

// NewCacheService creates a new cache service
func NewCacheService(redis *RedisClient, ttl time.Duration) *CacheService {
	return &CacheService{
		redis: redis,
		ttl:   ttl,
	}
}

// Product caching with Lazy Loading

// GetProduct retrieves a product from cache
func (c *CacheService) GetProduct(ctx context.Context, id int64) (*dto.ProductResponse, error) {
	if c.redis == nil {
		return nil, redis.Nil
	}

	key := fmt.Sprintf("product:%d", id)
	data, err := c.redis.Get(ctx, key)
	if err != nil {
		return nil, err
	}

	var product dto.ProductResponse
	if err := json.Unmarshal([]byte(data), &product); err != nil {
		return nil, err
	}

	log.Printf("Cache HIT: %s", key)
	return &product, nil
}

// SetProduct stores a product in cache
func (c *CacheService) SetProduct(ctx context.Context, product *dto.ProductResponse) error {
	if c.redis == nil {
		return nil
	}

	key := fmt.Sprintf("product:%d", product.ProductID)
	data, err := json.Marshal(product)
	if err != nil {
		return err
	}

	return c.redis.Set(ctx, key, data, c.ttl)
}

// DeleteProduct removes a product from cache
func (c *CacheService) DeleteProduct(ctx context.Context, id int64) error {
	if c.redis == nil {
		return nil
	}

	key := fmt.Sprintf("product:%d", id)
	return c.redis.Delete(ctx, key)
}

// Product list caching

// GetProductList retrieves a product list from cache
func (c *CacheService) GetProductList(ctx context.Context, page, pageSize int) (*dto.ProductListResponse, error) {
	if c.redis == nil {
		return nil, redis.Nil
	}

	key := fmt.Sprintf("products:list:%d:%d", page, pageSize)
	data, err := c.redis.Get(ctx, key)
	if err != nil {
		return nil, err
	}

	var productList dto.ProductListResponse
	if err := json.Unmarshal([]byte(data), &productList); err != nil {
		return nil, err
	}

	log.Printf("Cache HIT: %s", key)
	return &productList, nil
}

// SetProductList stores a product list in cache
func (c *CacheService) SetProductList(ctx context.Context, page, pageSize int, products *dto.ProductListResponse) error {
	if c.redis == nil {
		return nil
	}

	key := fmt.Sprintf("products:list:%d:%d", page, pageSize)
	data, err := json.Marshal(products)
	if err != nil {
		return err
	}

	// Shorter TTL for lists (2 minutes)
	return c.redis.Set(ctx, key, data, 2*time.Minute)
}

// InvalidateProductLists removes all product list caches
func (c *CacheService) InvalidateProductLists(ctx context.Context) error {
	if c.redis == nil {
		return nil
	}

	log.Println("Invalidating all product list caches")
	return c.redis.DeletePattern(ctx, "products:list:*")
}

// Inventory caching

// GetInventory retrieves inventory from cache
func (c *CacheService) GetInventory(ctx context.Context, productID int64) (*dto.InventoryResponse, error) {
	if c.redis == nil {
		return nil, redis.Nil
	}

	key := fmt.Sprintf("inventory:%d", productID)
	data, err := c.redis.Get(ctx, key)
	if err != nil {
		return nil, err
	}

	var inventory dto.InventoryResponse
	if err := json.Unmarshal([]byte(data), &inventory); err != nil {
		return nil, err
	}

	log.Printf("Cache HIT: %s", key)
	return &inventory, nil
}

// SetInventory stores inventory in cache
func (c *CacheService) SetInventory(ctx context.Context, inventory *dto.InventoryResponse) error {
	if c.redis == nil {
		return nil
	}

	key := fmt.Sprintf("inventory:%d", inventory.ProductID)
	data, err := json.Marshal(inventory)
	if err != nil {
		return err
	}

	// 3 minutes TTL for inventory
	return c.redis.Set(ctx, key, data, 3*time.Minute)
}

// DeleteInventory removes inventory from cache
func (c *CacheService) DeleteInventory(ctx context.Context, productID int64) error {
	if c.redis == nil {
		return nil
	}

	key := fmt.Sprintf("inventory:%d", productID)
	return c.redis.Delete(ctx, key)
}
