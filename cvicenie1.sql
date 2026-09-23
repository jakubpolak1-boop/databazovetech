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
    -------------------------------------

  SELECT 
    c.region, 
    SUM(o.sales) AS celkova_hodnota_predaja
FROM 
    customers AS c
JOIN 
    orders AS o ON c.customer_id = o.customer_id
GROUP BY 
    c.region;  
    -------------------------------------------------------------------------------ň

SELECT 
    p.product_name as PRODUKTY, 
    SUM(o.sales) AS celkova_hodnota_predaja
FROM 
    products AS p
LEFT JOIN 
    orders AS o ON p.product_id = o.product_id
GROUP BY 
    p.product_name;

------------------------------------------------------------------------    

SELECT 
    c.customer_name AS zakaznik, 
    o.order_id AS idečko_objednavky, 
    o.sales AS hodnota
FROM 
    customers AS c
FULL OUTER JOIN 
    orders AS o ON c.customer_id = o.customer_id;

--------      

