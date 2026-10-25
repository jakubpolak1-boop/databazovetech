-- Active: 1790056543991@@127.0.0.1@5432@superstore
WITH Sorted_Orders AS (
    SELECT 
        c.customer_name,
        o.order_id,
        o.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id 
            ORDER BY o.order_date DESC
        ) AS poradove_cislo
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
)

SELECT 
    customer_name,
    order_id,
    order_date
FROM Sorted_Orders
WHERE poradove_cislo <= 2
ORDER BY customer_name ASC, poradove_cislo ASC;

------------------------------------------------

WITH customer_profits AS (
    SELECT 
        c.region,
        c.customer_name,
        SUM(o.profit) AS total_profit
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.region, c.customer_name
)

SELECT 
    region,
    customer_name,
    total_profit,
    RANK() OVER (
        PARTITION BY region 
        ORDER BY total_profit DESC
    ) AS profit_rank,
    DENSE_RANK() OVER (
        PARTITION BY region 
        ORDER BY total_profit DESC
    ) AS profit_dense_rank
FROM customer_profits
ORDER BY region ASC, total_profit DESC;


-------------------------------------------------

WITH customers_sales AS (
    SELECT 
        c.customer_name,
        SUM(o.sales) AS total_sales
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_name
)
SELECT 
    customer_name,
    total_sales,
    NTILE(4) OVER (ORDER BY total_sales DESC) AS quartile
FROM customers_sales
ORDER BY total_sales DESC;

--------------------------------------------------

WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date)::DATE AS month,
        SUM(sales) AS monthly_sales
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)::DATE
)

SELECT 
    month,
    monthly_sales,
    LAG(monthly_sales, 1) OVER (ORDER BY month ASC) AS prev_month_sales,
    LEAD(monthly_sales, 1) OVER (ORDER BY month ASC) AS next_month_sales
FROM monthly_sales

--------------------------------------------------

WITH product_sales AS (
    SELECT 
        p.category,
        p.product_name,
        SUM(o.sales) AS product_sales
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category, p.product_name
)

SELECT 
    category,
    product_name,
    product_sales,
    SUM(product_sales) OVER (PARTITION BY category) AS category_total,
    ROUND(
        (product_sales * 100.0) / SUM(product_sales) OVER (PARTITION BY category), 
        2
    ) AS pct_of_category
FROM product_sales
ORDER BY category ASC, pct_of_category DESC;

--------------------------------------------------

WITH dates_customers AS (
    SELECT DISTINCT
        c.customer_id,
        c.customer_name,
        MAX(o.order_date) OVER (PARTITION BY c.customer_id) AS last_order_date,
        MAX(o.order_date) OVER () AS latest_order_date
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
)
SELECT 
    customer_id,
    customer_name,
    last_order_date
FROM dates_customers
WHERE last_order_date < latest_order_date - INTERVAL '90 days'
ORDER BY last_order_date ASC;