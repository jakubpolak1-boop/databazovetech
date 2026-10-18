-- Active: 1790056543991@@127.0.0.1@5432@retail
CREATE DATABASE retail

CREATE table retail_sales(
   invoice_no varchar(20),
   stock_code varchar(50),
   description text,
   quantity int,
   invoice_date TIMESTAMP,
    unit_price decimal(10,2),
    customer_id int,
    country varchar(100) 
);

-----------------------------------------
// da sa vyuzit aj CTE na rozkuskovanie teoreticky //

-------------------------------------------

WITH precalculated_sales AS (
    SELECT 
        customer_id,
        invoice_no,
        invoice_date,
        quantity,
        unit_price,
        (quantity * unit_price) AS revenue
    FROM retail_sales
    WHERE customer_id IS NOT NULL
)
SELECT 
    customer_id,
    invoice_no,
    invoice_date,
    quantity,
    unit_price,
    revenue,
    SUM(revenue) OVER (
        PARTITION BY customer_id
        ORDER BY invoice_date
        RANGE BETWEEN INTERVAL '14 days' PRECEDING AND CURRENT ROW
    ) AS revenue_last_14_days
FROM precalculated_sales
ORDER BY customer_id ASC, invoice_date ASC;

-----------------------------------------

SELECT 
    stock_code,
    country,
    invoice_date,
    quantity,
    ROUND(
        AVG(quantity) OVER (
            PARTITION BY stock_code, country 
            ORDER BY invoice_date
            RANGE BETWEEN INTERVAL '7 days' PRECEDING AND CURRENT ROW
        ), 2
    ) AS avg_quantity_7_days
FROM retail_sales
WHERE quantity > 1
ORDER BY stock_code, country, invoice_date;

--------------------------------------------

WITH unique_invoices AS (
    SELECT DISTINCT 
        customer_id, 
        invoice_no, 
        invoice_date::DATE AS invoice_date
    FROM retail_sales
    WHERE customer_id IS NOT NULL
),
next_purchases AS (
    SELECT 
        customer_id,
        invoice_no,
        invoice_date,
        LEAD(invoice_date) OVER (
            PARTITION BY customer_id 
            ORDER BY invoice_date
        ) AS next_invoice_date
    FROM unique_invoices
)
SELECT 
    customer_id,
    invoice_no,
    invoice_date,
    next_invoice_date,
    (next_invoice_date - invoice_date) AS days_to_next_invoice
FROM next_purchases
WHERE next_invoice_date IS NOT NULL
ORDER BY days_to_next_invoice DESC; 


---------------------------------------------------------

WITH price_history AS (
    SELECT 
        stock_code,
        invoice_no,
        invoice_date,
        LAG(unit_price) OVER (
            PARTITION BY stock_code 
            ORDER BY invoice_date
        ) AS previous_price,
        unit_price AS current_price
    FROM retail_sales
)
SELECT 
    stock_code,
    invoice_no,
    invoice_date,
    previous_price,
    current_price,
    (current_price - previous_price) AS price_difference
FROM price_history
WHERE previous_price IS NOT NULL 
  AND current_price != previous_price
ORDER BY invoice_date ASC;


------------------------------------------------------------

WITH customer_purchases AS (
    SELECT 
        customer_id,
        SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
)

SELECT 
    customer_id,
    total_amount,
    NTILE(4) OVER (ORDER BY total_amount DESC) AS sales_quartile
FROM customer_purchases
ORDER BY total_amount DESC;

---------------------------------------------------------------

WITH monthly_country_sales AS (
    SELECT 
        country,
        DATE_TRUNC('month', invoice_date)::DATE AS month,
        SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    GROUP BY country, DATE_TRUNC('month', invoice_date)::DATE
)

SELECT 
    country,
    month,
    total_amount,
    NTILE(4) OVER (
        PARTITION BY country 
        ORDER BY total_amount DESC
    ) AS sales_quartile
FROM monthly_country_sales
ORDER BY country ASC, month ASC;


-----------------------------------------------------

WITH divided_purchases AS (
    SELECT 
        customer_id,
        invoice_no,
        invoice_date,
        stock_code,
        description,
        quantity,
        unit_price,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY invoice_date ASC
        ) AS poradove_cislo
    FROM retail_sales
    WHERE customer_id IS NOT NULL
)
SELECT 
    customer_id,
    invoice_no,
    invoice_date,
    stock_code,
    description,
    quantity,
    unit_price
FROM divided_purchases
WHERE poradove_cislo = 1
ORDER BY customer_id ASC;

-----------------------------------------------------

WITH divided_items AS (
    SELECT 
        invoice_no,
        stock_code,
        description,
        quantity,
        unit_price,
        (quantity * unit_price) AS amount,
        ROW_NUMBER() OVER (
            PARTITION BY invoice_no 
            ORDER BY (quantity * unit_price) DESC
        ) AS row_num
    FROM retail_sales
)

SELECT 
    invoice_no,
    stock_code,
    description,
    quantity,
    unit_price,
    amount,
    row_num
FROM divided_items
WHERE row_num <= 3
ORDER BY invoice_no ASC, row_num ASC;

------------------------------------------------------

WITH monthly_customer_spending AS (
    SELECT 
        country,
        DATE_TRUNC('month', invoice_date)::DATE AS month,
        customer_id,
        SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    WHERE customer_id IS NOT NULL
    GROUP BY country, DATE_TRUNC('month', invoice_date)::DATE, customer_id
),

devided_customers AS (
    SELECT 
        country,
        month,
        customer_id,
        total_amount,
        DENSE_RANK() OVER (
            PARTITION BY country, month 
            ORDER BY total_amount DESC
        ) AS sales_rank
    FROM monthly_customer_spending
)

SELECT 
    country,
    month,
    customer_id,
    total_amount,
    sales_rank
FROM devided_customers
WHERE sales_rank <= 5
ORDER BY country ASC, month ASC, sales_rank ASC, customer_id ASC;

-------------------------------------------------------

WITH sorted_prices AS (
    SELECT
        invoice_no,
        stock_code,
        description,
        quantity,
        unit_price,
        DENSE_RANK() OVER (
            PARTITION BY invoice_no
            ORDER BY unit_price DESC
        ) as price_rank
    FROM retail_sales
)
SELECT 
    invoice_no,
    stock_code,
    description,
    quantity,
    unit_price,
    price_rank
FROM sorted_prices
WHERE price_rank <= 5
ORDER BY invoice_no ASC, price_rank ASC, stock_code ASC;

--------------------------------------------------------



    
        


