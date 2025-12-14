package cache

import (
	"context"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
)

// RedisClient wraps the Redis client
type RedisClient struct {
	client *redis.Client
}

// NewRedisClient creates a new Redis client
func NewRedisClient(endpoint, port, password string) (*RedisClient, error) {
	// Skip Redis if endpoint is not configured
	if endpoint == "" {
		return nil, nil
	}

	addr := fmt.Sprintf("%s:%s", endpoint, port)

	client := redis.NewClient(&redis.Options{
		Addr:         addr,
		Password:     password,
		DB:           0,
		DialTimeout:  5 * time.Second,
		ReadTimeout:  3 * time.Second,
		WriteTimeout: 3 * time.Second,
		PoolSize:     10,
		MinIdleConns: 5,
	})

	// Test connection
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := client.Ping(ctx).Err(); err != nil {
		return nil, fmt.Errorf("failed to connect to Redis: %w", err)
	}

	return &RedisClient{client: client}, nil
}

// Get retrieves a value from Redis
func (r *RedisClient) Get(ctx context.Context, key string) (string, error) {
	if r == nil || r.client == nil {
		return "", redis.Nil
	}
	return r.client.Get(ctx, key).Result()
}

// Set stores a value in Redis with TTL
func (r *RedisClient) Set(ctx context.Context, key string, value interface{}, ttl time.Duration) error {
	if r == nil || r.client == nil {
		return nil
	}
	return r.client.Set(ctx, key, value, ttl).Err()
}

// Delete removes keys from Redis
func (r *RedisClient) Delete(ctx context.Context, keys ...string) error {
	if r == nil || r.client == nil {
		return nil
	}
	return r.client.Del(ctx, keys...).Err()
}

// DeletePattern deletes all keys matching a pattern
func (r *RedisClient) DeletePattern(ctx context.Context, pattern string) error {
	if r == nil || r.client == nil {
		return nil
	}

	var cursor uint64
	for {
		var keys []string
		var err error
		keys, cursor, err = r.client.Scan(ctx, cursor, pattern, 100).Result()
		if err != nil {
			return err
		}

		if len(keys) > 0 {
			if err := r.client.Del(ctx, keys...).Err(); err != nil {
				return err
			}
		}

		if cursor == 0 {
			break
		}
	}

	return nil
}

// Close closes the Redis connection
func (r *RedisClient) Close() error {
	if r == nil || r.client == nil {
		return nil
	}
	return r.client.Close()
}
