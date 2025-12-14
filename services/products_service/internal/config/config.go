package config

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
)

// Config holds application configuration
type Config struct {
	Environment   string
	LogLevel      string
	DBHost        string
	DBPort        string
	DBName        string
	DBUser        string
	DBPassword    string
	AWSRegion     string
	RedisEndpoint string
	RedisPort     string
	CacheTTL      time.Duration
}

// DBSecret represents the structure of database credentials in Secrets Manager
type DBSecret struct {
	Host     string `json:"host"`
	Port     int    `json:"port"`
	DBName   string `json:"dbname"`
	Username string `json:"username"`
	Password string `json:"password"`
}

// LoadConfig loads configuration from environment variables
func LoadConfig() (*Config, error) {
	config := &Config{
		Environment:   getEnv("ENVIRONMENT", "dev"),
		LogLevel:      getEnv("LOG_LEVEL", "INFO"),
		AWSRegion:     getEnv("AWS_REGION", "us-east-1"),
		RedisEndpoint: getEnv("REDIS_ENDPOINT", ""),
		RedisPort:     getEnv("REDIS_PORT", "6379"),
		CacheTTL:      5 * time.Minute, // Default 5 minutes
	}

	if config.Environment == "dev" {
		config.loadLocalEnv()
	} else {
		if err := config.loadProdEnv(); err != nil {
			return nil, err
		}
	}

	return config, nil
}

// loadLocalEnv loads configuration from environment variables for local development
func (c *Config) loadLocalEnv() {
	c.DBHost = getEnv("DB_HOST", "localhost")
	c.DBPort = getEnv("DB_PORT", "3306")
	c.DBName = getEnv("DB_NAME", "ecommerce")
	c.DBUser = getEnv("DB_USER", "root")
	c.DBPassword = getEnv("DB_PASSWORD", "password")
}

// loadProdEnv loads configuration from AWS Secrets Manager for production
func (c *Config) loadProdEnv() error {
	// Try to load from environment variables first
	c.DBHost = os.Getenv("DB_HOST")
	c.DBPort = os.Getenv("DB_PORT")
	c.DBName = os.Getenv("DB_NAME")
	c.DBUser = os.Getenv("DB_USER")
	c.DBPassword = os.Getenv("DB_PASSWORD")

	// If any required setting is missing, fetch from Secrets Manager
	if c.DBHost == "" || c.DBPort == "" || c.DBName == "" || c.DBUser == "" || c.DBPassword == "" {
		log.Println("Some database settings not found in environment variables, fetching from Secrets Manager")

		secretName := fmt.Sprintf("%s/rds/credentials", c.Environment)

		// Create AWS session
		sess, err := session.NewSession(&aws.Config{
			Region: aws.String(c.AWSRegion),
		})
		if err != nil {
			return fmt.Errorf("failed to create AWS session: %w", err)
		}

		// Create Secrets Manager client
		svc := secretsmanager.New(sess)

		// Get secret value
		input := &secretsmanager.GetSecretValueInput{
			SecretId: aws.String(secretName),
		}

		result, err := svc.GetSecretValue(input)
		if err != nil {
			return fmt.Errorf("failed to retrieve secret from Secrets Manager: %w", err)
		}

		// Parse secret JSON
		var secret DBSecret
		if err := json.Unmarshal([]byte(*result.SecretString), &secret); err != nil {
			return fmt.Errorf("failed to parse secret JSON: %w", err)
		}

		// Set database connection parameters from secrets
		c.DBHost = secret.Host
		c.DBPort = fmt.Sprintf("%d", secret.Port)
		c.DBName = secret.DBName
		c.DBUser = secret.Username
		c.DBPassword = secret.Password

		log.Printf("Successfully loaded database configuration from Secrets Manager for %s environment", c.Environment)
	} else {
		log.Println("Using database configuration from environment variables")
	}

	return nil
}

// GetDSN returns the database connection string
func (c *Config) GetDSN() string {
	return fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local",
		c.DBUser, c.DBPassword, c.DBHost, c.DBPort, c.DBName)
}

// getEnv gets an environment variable with a default value
func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}
