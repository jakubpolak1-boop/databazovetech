-- Active: 1790056543991@@127.0.0.1@5432@superstore
CREATE DATABASE superstore; 

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    region VARCHAR(50)
);

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(100)
); 

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    product_id VARCHAR(20),
    order_date DATE,
    ship_date DATE,
    sales NUMERIC(10, 2),
    quantity INT,
    discount NUMERIC(10, 2),
    profit NUMERIC(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;


----------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    o.order_id, 
    c.customer_name, 
    o.sales
FROM 
    orders AS o
JOIN 
    customers AS c ON o.customer_id = c.customer_id
WHERE 
    o.sales > 500
ORDER BY 
    o.sales DESC;
-----------------------------------------------------------------------------------------------
SELECT 
    o.order_id, 
    c.customer_name, 
    p.category, 
    o.sales
FROM 
    orders AS o
JOIN 
    customers AS c ON o.customer_id = c.customer_id
JOIN 
    products AS p ON o.product_id = p.product_id;