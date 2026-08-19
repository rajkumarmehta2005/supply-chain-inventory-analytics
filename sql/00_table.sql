
CREATE DATABASE IF NOT EXISTS supply_chain;

USE supply_chain;

CREATE TABLE suppliers (
    supplier_id VARCHAR(20) PRIMARY KEY,
    supplier_name VARCHAR(100),
    supplier_city VARCHAR(100),
    supplier_state VARCHAR(100),
    supplier_rating DECIMAL(5,2),
    payment_terms VARCHAR(50)
);

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    unit_cost DECIMAL(12,2),
    selling_price DECIMAL(12,2),
    reorder_level INT,
    safety_stock INT,
    supplier_id VARCHAR(20),
    profit_per_unit DECIMAL(12,2),
    profit_margin DECIMAL(10,4),

    FOREIGN KEY (supplier_id)
        REFERENCES suppliers(supplier_id)
);

CREATE TABLE inventory (
    inventory_id VARCHAR(20) PRIMARY KEY,
    product_id VARCHAR(20),
    warehouse VARCHAR(100),
    inventory_date DATE,
    opening_stock INT,
    units_received INT,
    units_sold INT,
    closing_stock INT,
    damaged_units INT,
    stockout_flag INT,
    average_stock DECIMAL(12,2),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    order_date DATE,
    product_id VARCHAR(20),
    customer_id VARCHAR(20),
    warehouse VARCHAR(100),
    quantity INT,
    unit_price DECIMAL(12,2),
    sales DECIMAL(14,2),
    order_status VARCHAR(50),
    delivery_date DATE,
    order_year INT,
    order_month INT,
    order_month_name VARCHAR(20),
    fulfilled_flag INT,

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

CREATE TABLE procurement (
    procurement_id VARCHAR(20) PRIMARY KEY,
    po_date DATE,
    supplier_id VARCHAR(20),
    product_id VARCHAR(20),
    warehouse VARCHAR(100),
    quantity_ordered INT,
    quantity_received INT,
    unit_cost DECIMAL(12,2),
    procurement_cost DECIMAL(14,2),
    expected_delivery_date DATE,
    actual_delivery_date DATE,

    FOREIGN KEY (supplier_id)
        REFERENCES suppliers(supplier_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);