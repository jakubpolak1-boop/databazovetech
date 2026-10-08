-- Active: 1790056543991@@127.0.0.1@5432@superstore
SELECT *
from superstore


-----------------------------------------

CREATE VIEW high_value_customers AS
SELECT c.customer_id,
       c.customer_name,
       SUM(o.sales) AS total_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id,
         c.customer_name
HAVING SUM(o.sales) > 2000;


SELECT *
FROM high_value_customers;

--------------------------------------------------
CREATE VIEW regional_monthly_sales AS
SELECT c.region,
       DATE_TRUNC('month', o.order_date) AS month,
       SUM(o.sales) AS monthly_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.region,
         DATE_TRUNC('month', o.order_date);


SELECT *
FROM regional_monthly_sales;

SELECT *
FROM regional_monthly_sales
WHERE region = 'West'
ORDER BY month ASC;

------------------------------------------------------

CREATE VIEW analyst_orders AS
SELECT order_id,
       customer_id,
       product_id,
       sales,
       quantity,
       discount
FROM orders;



SELECT *
FROM analyst_orders;

-------------------------------------------------------

