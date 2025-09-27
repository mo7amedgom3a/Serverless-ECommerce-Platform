-- Users Table
CREATE TABLE users (
    user_id         BIGSERIAL PRIMARY KEY,         -- Auto-increment PK
    name            VARCHAR(100) NOT NULL,
    email           VARCHAR(255) NOT NULL UNIQUE,
    hashed_password TEXT NOT NULL,
    address         TEXT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products Table
CREATE TABLE products (
    product_id      BIGSERIAL PRIMARY KEY,
    sku             VARCHAR(100) NOT NULL UNIQUE,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    price           DECIMAL(10,2) NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ProductInventory Table
CREATE TABLE product_inventory (
    inventory_id        BIGSERIAL PRIMARY KEY,
    product_id          BIGINT NOT NULL,
    stock_quantity      INT NOT NULL DEFAULT 0,
    warehouse_location  VARCHAR(255),
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_inventory_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE CASCADE
);

-- Orders Table
CREATE TABLE orders (
    order_id        BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL,
    status          VARCHAR(50) NOT NULL DEFAULT 'PENDING',  -- PENDING, PAID, SHIPPED
    order_total     DECIMAL(10,2) NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_order_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- OrderItems Table
CREATE TABLE order_items (
    order_item_id   BIGSERIAL PRIMARY KEY,
    order_id        BIGINT NOT NULL,
    product_id      BIGINT NOT NULL,
    quantity        INT NOT NULL DEFAULT 1,
    price_at_order  DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_order_item_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Shipments Table
CREATE TABLE shipments (
    shipment_id     BIGSERIAL PRIMARY KEY,
    order_id        BIGINT NOT NULL,
    carrier         VARCHAR(100),
    tracking_number VARCHAR(255),
    status          VARCHAR(50) DEFAULT 'PROCESSING',  -- PROCESSING, IN_TRANSIT, DELIVERED
    shipped_at      TIMESTAMP,

    CONSTRAINT fk_shipment_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE
);

