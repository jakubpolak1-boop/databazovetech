\set ON_ERROR_STOP on

CREATE SCHEMA IF NOT EXISTS gold;

-- dim_customer
CREATE TABLE IF NOT EXISTS gold.dim_customer (
customer_id INT PRIMARY KEY,
customer_name VARCHAR(100) NOT NULL,
contact_name VARCHAR(100),
address VARCHAR(200),
city VARCHAR(100),
postal_code VARCHAR(20),
country VARCHAR(100)
);

-- dim_product
CREATE TABLE IF NOT EXISTS gold.dim_product (
product_id INT PRIMARY KEY,
product_name VARCHAR(100) NOT NULL,
category_name VARCHAR(100),
category_description TEXT,
supplier_name VARCHAR(100),
supplier_country VARCHAR(100),
unit VARCHAR(100),
price NUMERIC(10,2) NOT NULL
);

-- dim_employee
CREATE TABLE IF NOT EXISTS gold.dim_employee (
employee_id INT PRIMARY KEY,
first_name VARCHAR(100),
last_name VARCHAR(100),
birth_date DATE
);

-- dim_shipper
CREATE TABLE IF NOT EXISTS gold.dim_shipper (
shipper_id INT PRIMARY KEY,
shipper_name VARCHAR(100),
phone VARCHAR(30)
);

-- dim_date
CREATE TABLE IF NOT EXISTS gold.dim_date (
date_id INT PRIMARY KEY,
order_date DATE NOT NULL UNIQUE,
day INT NOT NULL,
month INT NOT NULL,
year INT NOT NULL,
day_of_week INT NOT NULL,
day_name VARCHAR(10) NOT NULL,
week INT NOT NULL,
month_name VARCHAR(10) NOT NULL,
quarter INT NOT NULL
);

-- fact_order
CREATE TABLE IF NOT EXISTS gold.fact_order (
order_detail_id INT PRIMARY KEY,
order_id INT NOT NULL,
customer_id INT NOT NULL REFERENCES gold.dim_customer(customer_id),
product_id INT NOT NULL REFERENCES gold.dim_product(product_id),
employee_id INT NOT NULL REFERENCES gold.dim_employee(employee_id),
shipper_id INT NOT NULL REFERENCES gold.dim_shipper(shipper_id),
date_id INT NOT NULL REFERENCES gold.dim_date(date_id),
quantity INT NOT NULL,
price NUMERIC(10,2) NOT NULL,
total_price NUMERIC(12,2) NOT NULL -- quantity * price
);

-- indexy na cudzie kluce
CREATE INDEX IF NOT EXISTS fact_order_customer_idx ON gold.fact_order(customer_id);
CREATE INDEX IF NOT EXISTS fact_order_product_idx ON gold.fact_order(product_id);
CREATE INDEX IF NOT EXISTS fact_order_employee_idx ON gold.fact_order(employee_id);
CREATE INDEX IF NOT EXISTS fact_order_shipper_idx ON gold.fact_order(shipper_id);
CREATE INDEX IF NOT EXISTS fact_order_date_idx ON gold.fact_order(date_id);

BEGIN;

TRUNCATE gold.fact_order,
gold.dim_customer,
gold.dim_product,
gold.dim_employee,
gold.dim_shipper,
gold.dim_date;

INSERT INTO gold.dim_customer (
customer_id,
customer_name,
contact_name,
address,
city,
postal_code,
country
)
SELECT customer_id, customer_name, contact_name, address, city, postal_code, country
FROM silver.stg_customers
ORDER BY customer_id;

INSERT INTO gold.dim_product (
product_id,
product_name,
category_name,
category_description,
supplier_name,
supplier_country,
unit,
price
)
SELECT p.product_id, p.product_name, c.category_name, c.description,
       s.supplier_name, s.country, p.unit, p.price
FROM silver.stg_products p
LEFT JOIN silver.stg_categories c ON c.category_id = p.category_id
LEFT JOIN silver.stg_suppliers s ON s.supplier_id = p.supplier_id
ORDER BY p.product_id;

INSERT INTO gold.dim_employee (employee_id, first_name, last_name, birth_date)
SELECT employee_id, first_name, last_name, birth_date::DATE
FROM silver.stg_employees
ORDER BY employee_id;

INSERT INTO gold.dim_shipper (shipper_id, shipper_name, phone)
SELECT shipper_id, shipper_name, phone
FROM silver.stg_shippers
ORDER BY shipper_id;

INSERT INTO gold.dim_date (
date_id,
order_date,
day,
month,
year,
day_of_week,
day_name,
week,
month_name,
quarter
)
SELECT DISTINCT
    TO_CHAR(order_date, 'YYYYMMDD')::INT,
    order_date::DATE,
    EXTRACT(DAY FROM order_date)::INT,
    EXTRACT(MONTH FROM order_date)::INT,
    EXTRACT(YEAR FROM order_date)::INT,
    EXTRACT(ISODOW FROM order_date)::INT,
    TO_CHAR(order_date, 'FMDay'),
    EXTRACT(WEEK FROM order_date)::INT,
    TO_CHAR(order_date, 'FMMonth'),
    EXTRACT(QUARTER FROM order_date)::INT
FROM silver.stg_orders
ORDER BY 1;

-- jedna polozka objednavky = jeden riadok
-- cena je z tabulky products, v orderdetails cena nie je
INSERT INTO gold.fact_order (
order_detail_id,
order_id,
customer_id,
product_id,
employee_id,
shipper_id,
date_id,
quantity,
price,
total_price
)
SELECT d.order_detail_id, o.order_id, o.customer_id, d.product_id,
       o.employee_id, o.shipper_id, dt.date_id, d.quantity, p.price,
       d.quantity * p.price
FROM silver.stg_orderdetails d
JOIN silver.stg_orders o ON o.order_id = d.order_id
JOIN silver.stg_products p ON p.product_id = d.product_id
JOIN gold.dim_date dt ON dt.order_date = o.order_date::DATE
ORDER BY d.order_detail_id;

COMMIT;

-- kontrola
SELECT * FROM gold.fact_order ORDER BY order_detail_id LIMIT 10;
SELECT COUNT(*) FROM gold.fact_order;