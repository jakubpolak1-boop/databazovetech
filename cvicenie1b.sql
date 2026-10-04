-- Active: 1790056543991@@127.0.0.1@5432@datacraftinglab_db
CREATE DATABASE datacraftinglab_db;

CREATE TABLE flourmills_sales (
    sales_id INT PRIMARY KEY,
    sale_date DATE,
    region VARCHAR(100),
    state VARCHAR(100),
    product_category VARCHAR(100),
    product_name VARCHAR(150),
    customer_type VARCHAR(100),
    customer_id INT,
    quantity_sold INT,
    unit_price DECIMAL(10, 2),
    discount_rate INT,
    payment_method VARCHAR(100),
    sales_rep VARCHAR(150),
    warehouse VARCHAR(100),
    delivery_status VARCHAR(100),
    order_channel VARCHAR(100),
    batch_number INT,
    production_date DATE,
    total_amount DECIMAL(10, 2)
);

SELECT *
FROM flourmills_sales





--------------------------
SELECT 
    product_name, 
    total_amount
FROM 
    flourmills_sales
WHERE 
    total_amount > (
        SELECT AVG(total_amount) 
        FROM flourmills_sales
    );

-----------------------

SELECT *
FROM flourmills_sales
WHERE product_category = (
    SELECT product_category
    FROM flourmills_sales
    GROUP BY product_category
    ORDER BY SUM(total_amount) DESC
    LIMIT 1
)
ORDER BY sales_id ASC;



--------------------------------

SELECT 
    product_name,
    total_amount,
    (SELECT AVG(total_amount) FROM flourmills_sales) AS avg_amount
FROM 
    flourmills_sales;

------------------------------

SELECT 
    product_name,
    total_amount,
    total_amount / (SELECT SUM(total_amount) FROM flourmills_sales) AS amount_share
FROM 
    flourmills_sales;

--------------------------------------------------

SELECT 
    month, 
    monthly_sales
FROM (
    SELECT 
        EXTRACT(MONTH FROM sale_date) AS month,
        SUM(total_amount) AS monthly_sales
    FROM 
        flourmills_sales
    GROUP BY 
        EXTRACT(MONTH FROM sale_date)
) AS monthly_summary
ORDER BY 
    monthly_sales DESC;

-------------------------------------------

SELECT 
    product_category,
    total_sales
FROM (
    SELECT 
        product_category,
        SUM(total_amount) AS total_sales
    FROM 
        flourmills_sales
    GROUP BY 
        product_category
) AS sumarkategorie
WHERE 
    total_sales > 50000000
ORDER BY 
    total_sales DESC; 

------------------------------------------
SELECT 
    product_name,
    product_category,
    total_amount
FROM 
    flourmills_sales t1
WHERE 
    total_amount > (
        SELECT AVG(total_amount) 
        FROM flourmills_sales t2 
        WHERE t2.product_category = t1.product_category
    );


-----------------------------------
SELECT 
    product_name,
    region,
    total_amount,
    (SELECT MIN(total_amount) 
     FROM flourmills_sales t2 
     WHERE t2.region = t1.region) AS region_min_amount
FROM 
    flourmills_sales t1


-----------------------------
SELECT *
FROM flourmills_sales t1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t2.product_name = t1.product_name
    GROUP BY t2.product_name
    HAVING COUNT(DISTINCT EXTRACT(MONTH FROM t2.sale_date)) > 1
);

-------------------------------
SELECT *
FROM flourmills_sales t1
WHERE EXISTS (
    SELECT 1 
    FROM flourmills_sales t2 
    WHERE t2.product_category = t1.product_category 
      AND t2.total_amount > 200000
);

------------------------------

SELECT DISTINCT product_category
FROM flourmills_sales t1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t2.product_category = t1.product_category
    GROUP BY t2.product_category
    HAVING COUNT(DISTINCT t2.region) > 3
);

---------------------------------

SELECT *
FROM flourmills_sales t1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t2.region = t1.region
      AND EXTRACT(YEAR FROM t2.sale_date) = 2024
);

-----------------------------------

SELECT DISTINCT product_category
FROM flourmills_sales t1
WHERE NOT EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t2.product_category = t1.product_category
      AND t2.total_amount > 500000
);


-------------------------------------

SELECT DISTINCT region
FROM flourmills_sales t1
WHERE NOT EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t2.region = t1.region
      AND t2.product_category = 'Flour'
);