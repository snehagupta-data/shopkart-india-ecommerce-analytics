-- ============================================================
-- SHOPKART INDIA E-COMMERCE ANALYTICS
-- FINAL POSTGRESQL DATABASE SCHEMA
-- ============================================================

-- ============================================================
-- 0. CREATE SCHEMA
-- ============================================================

CREATE SCHEMA IF NOT EXISTS shopkart;

SET search_path TO shopkart;


-- ============================================================
-- 1. CATEGORIES
-- ============================================================

DROP TABLE IF EXISTS returns CASCADE;
DROP TABLE IF EXISTS shipments CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS sellers CASCADE;
DROP TABLE IF EXISTS warehouses CASCADE;
DROP TABLE IF EXISTS delivery_partners CASCADE;
DROP TABLE IF EXISTS locations CASCADE;
DROP TABLE IF EXISTS categories CASCADE;


CREATE TABLE categories (
    category_id VARCHAR(20) PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    subcategory_name VARCHAR(100) NOT NULL,

    CONSTRAINT uq_category_subcategory
        UNIQUE (category_name, subcategory_name)
);


-- ============================================================
-- 2. LOCATIONS
-- ============================================================

CREATE TABLE locations (
    location_id VARCHAR(20) PRIMARY KEY,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    city_tier VARCHAR(30),
    pincode_prefix VARCHAR(10)
);


-- ============================================================
-- 3. DELIVERY PARTNERS
-- ============================================================

CREATE TABLE delivery_partners (
    delivery_partner_id VARCHAR(20) PRIMARY KEY,
    delivery_partner_name VARCHAR(150) NOT NULL,
    service_region VARCHAR(100),
    partner_type VARCHAR(100),
    partner_rating NUMERIC(3,2),

    CONSTRAINT chk_partner_rating
        CHECK (
            partner_rating IS NULL
            OR partner_rating BETWEEN 0 AND 5
        )
);


-- ============================================================
-- 4. WAREHOUSES
-- ============================================================

CREATE TABLE warehouses (
    warehouse_id VARCHAR(20) PRIMARY KEY,
    warehouse_name VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    location_id VARCHAR(20) NOT NULL,
    warehouse_type VARCHAR(100),
    capacity_band VARCHAR(50),

    CONSTRAINT fk_warehouse_location
        FOREIGN KEY (location_id)
        REFERENCES locations(location_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- ============================================================
-- 5. SELLERS
-- ============================================================

CREATE TABLE sellers (
    seller_id VARCHAR(30) PRIMARY KEY,
    seller_name VARCHAR(150) NOT NULL,
    registration_date DATE NOT NULL,
    seller_city VARCHAR(100),
    seller_state VARCHAR(100),
    seller_location_id VARCHAR(20) NOT NULL,
    seller_rating NUMERIC(3,2),
    seller_type VARCHAR(100),
    fulfillment_type VARCHAR(100),

    CONSTRAINT fk_seller_location
        FOREIGN KEY (seller_location_id)
        REFERENCES locations(location_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_seller_rating
        CHECK (
            seller_rating IS NULL
            OR seller_rating BETWEEN 0 AND 5
        )
);


-- ============================================================
-- 6. PRODUCTS
-- ============================================================

CREATE TABLE products (
    product_id VARCHAR(30) PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category_id VARCHAR(20) NOT NULL,
    brand VARCHAR(100),
    seller_id VARCHAR(30) NOT NULL,
    product_cost NUMERIC(12,2) NOT NULL,
    list_price NUMERIC(12,2) NOT NULL,
    launch_date DATE,
    product_rating NUMERIC(3,2),

    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_product_seller
        FOREIGN KEY (seller_id)
        REFERENCES sellers(seller_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_product_cost
        CHECK (product_cost >= 0),

    CONSTRAINT chk_list_price
        CHECK (list_price >= 0),

    CONSTRAINT chk_product_rating
        CHECK (
            product_rating IS NULL
            OR product_rating BETWEEN 0 AND 5
        )
);


-- ============================================================
-- 7. CUSTOMERS
-- ============================================================

CREATE TABLE customers (
    customer_id VARCHAR(30) PRIMARY KEY,
    registration_date DATE NOT NULL,
    gender VARCHAR(30),
    date_of_birth DATE,
    city VARCHAR(100),
    state VARCHAR(100),
    location_id VARCHAR(20) NOT NULL,
    acquisition_channel VARCHAR(100),
    customer_segment VARCHAR(50),

    CONSTRAINT fk_customer_location
        FOREIGN KEY (location_id)
        REFERENCES locations(location_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- ============================================================
-- 8. ORDERS
-- ============================================================

CREATE TABLE orders (
    order_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(30) NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(50) NOT NULL,
    order_channel VARCHAR(50),
    shipping_location_id VARCHAR(20),
    warehouse_id VARCHAR(20),
    payment_id VARCHAR(30),
    shipment_id VARCHAR(30),
    order_subtotal NUMERIC(12,2) NOT NULL,
    discount_amount NUMERIC(12,2) NOT NULL,
    shipping_fee NUMERIC(12,2) NOT NULL,
    order_total NUMERIC(12,2) NOT NULL,

    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_order_shipping_location
        FOREIGN KEY (shipping_location_id)
        REFERENCES locations(location_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_order_warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses(warehouse_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_order_subtotal
        CHECK (order_subtotal >= 0),

    CONSTRAINT chk_order_discount
        CHECK (discount_amount >= 0),

    CONSTRAINT chk_shipping_fee
        CHECK (shipping_fee >= 0),

    CONSTRAINT chk_order_total
        CHECK (order_total >= 0)
);


-- ============================================================
-- 9. ORDER ITEMS
-- ============================================================

CREATE TABLE order_items (
    order_item_id VARCHAR(30) PRIMARY KEY,
    order_id VARCHAR(30) NOT NULL,
    product_id VARCHAR(30) NOT NULL,
    seller_id VARCHAR(30) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_list_price NUMERIC(12,2) NOT NULL,
    unit_selling_price NUMERIC(12,2) NOT NULL,
    discount_percent NUMERIC(5,2) NOT NULL,
    discount_amount NUMERIC(12,2) NOT NULL,
    product_cost NUMERIC(12,2) NOT NULL,
    item_revenue NUMERIC(12,2) NOT NULL,
    item_cost NUMERIC(12,2) NOT NULL,
    item_profit NUMERIC(12,2) NOT NULL,

    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_order_item_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_order_item_seller
        FOREIGN KEY (seller_id)
        REFERENCES sellers(seller_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_unit_list_price
        CHECK (unit_list_price >= 0),

    CONSTRAINT chk_unit_selling_price
        CHECK (unit_selling_price >= 0),

    CONSTRAINT chk_discount_percent
        CHECK (
            discount_percent BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_discount_amount
        CHECK (discount_amount >= 0),

    CONSTRAINT chk_product_cost_item
        CHECK (product_cost >= 0),

    CONSTRAINT chk_item_revenue
        CHECK (item_revenue >= 0),

    CONSTRAINT chk_item_cost
        CHECK (item_cost >= 0)
);


-- ============================================================
-- 10. PAYMENTS
-- ============================================================

CREATE TABLE payments (
    payment_id VARCHAR(30) PRIMARY KEY,
    order_id VARCHAR(30) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(50) NOT NULL,
    payment_amount NUMERIC(12,2) NOT NULL,

    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_payment_amount
        CHECK (payment_amount >= 0)
);


-- ============================================================
-- 11. SHIPMENTS
-- ============================================================

CREATE TABLE shipments (
    shipment_id VARCHAR(30) PRIMARY KEY,
    order_id VARCHAR(30) NOT NULL,
    warehouse_id VARCHAR(20) NOT NULL,
    delivery_partner_id VARCHAR(20) NOT NULL,
    shipping_date DATE,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    delivery_status VARCHAR(50) NOT NULL,
    delivery_delay_days INTEGER,

    CONSTRAINT fk_shipment_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_shipment_warehouse
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses(warehouse_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_shipment_delivery_partner
        FOREIGN KEY (delivery_partner_id)
        REFERENCES delivery_partners(delivery_partner_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- ============================================================
-- 12. RETURNS
-- ============================================================

CREATE TABLE returns (
    return_id VARCHAR(30) PRIMARY KEY,
    order_id VARCHAR(30) NOT NULL,
    order_item_id VARCHAR(30) NOT NULL,
    product_id VARCHAR(30) NOT NULL,
    return_date DATE NOT NULL,
    return_reason VARCHAR(150) NOT NULL,
    return_status VARCHAR(50) NOT NULL,
    refund_amount NUMERIC(12,2) NOT NULL,
    return_cost NUMERIC(12,2) NOT NULL,

    CONSTRAINT fk_return_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_return_order_item
        FOREIGN KEY (order_item_id)
        REFERENCES order_items(order_item_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_return_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_refund_amount
        CHECK (refund_amount >= 0),

    CONSTRAINT chk_return_cost
        CHECK (return_cost >= 0)
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_warehouses_location
    ON warehouses(location_id);

CREATE INDEX idx_sellers_location
    ON sellers(seller_location_id);

CREATE INDEX idx_products_category
    ON products(category_id);

CREATE INDEX idx_products_seller
    ON products(seller_id);

CREATE INDEX idx_customers_location
    ON customers(location_id);

CREATE INDEX idx_customers_registration_date
    ON customers(registration_date);

CREATE INDEX idx_orders_customer
    ON orders(customer_id);

CREATE INDEX idx_orders_date
    ON orders(order_date);

CREATE INDEX idx_orders_status
    ON orders(order_status);

CREATE INDEX idx_orders_warehouse
    ON orders(warehouse_id);

CREATE INDEX idx_order_items_order
    ON order_items(order_id);

CREATE INDEX idx_order_items_product
    ON order_items(product_id);

CREATE INDEX idx_order_items_seller
    ON order_items(seller_id);

CREATE INDEX idx_payments_order
    ON payments(order_id);

CREATE INDEX idx_payments_status
    ON payments(payment_status);

CREATE INDEX idx_shipments_order
    ON shipments(order_id);

CREATE INDEX idx_shipments_warehouse
    ON shipments(warehouse_id);

CREATE INDEX idx_shipments_partner
    ON shipments(delivery_partner_id);

CREATE INDEX idx_shipments_status
    ON shipments(delivery_status);

CREATE INDEX idx_returns_order
    ON returns(order_id);

CREATE INDEX idx_returns_order_item
    ON returns(order_item_id);

CREATE INDEX idx_returns_product
    ON returns(product_id);

CREATE INDEX idx_returns_date
    ON returns(return_date);


-- ============================================================
-- DONE
-- ============================================================

SELECT
    table_name
FROM information_schema.tables
WHERE table_schema = 'shopkart'
ORDER BY table_name;