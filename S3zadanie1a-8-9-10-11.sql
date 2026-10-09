-- Active: 1790056543991@@127.0.0.1@5432@retail_sales


CREATE DATABASE retail_sales;
ALTER DATABASE retail_sales SET datestyle TO 'ISO, MDY';

CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    region VARCHAR(20) NOT NULL,
    category VARCHAR(50) NOT NULL,
    ship_mode VARCHAR(30) NOT NULL,
    sales NUMERIC(10,2) NOT NULL,
    profit NUMERIC(10,2) NOT NULL
);

SELECT COUNT(*) FROM orders;

-----------------------------------------------------

CREATE OR REPLACE PROCEDURE get_customer_sales(
    p_customer_id VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_sales NUMERIC(10,2);
BEGIN
    SELECT SUM(sales)
    INTO v_total_sales
    FROM orders
    WHERE customer_id = p_customer_id;

    RAISE NOTICE 'Zákazník % má celkový predaj: %', p_customer_id, COALESCE(v_total_sales, 0);
END;
$$;

CALL get_customer_sales('C001');


----------------------------------------------------

CREATE OR REPLACE PROCEDURE apply_regional_discount(
    p_region_name VARCHAR(20),
    p_discount_rate NUMERIC(5,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE orders
    SET sales = sales * (1 - p_discount_rate)
    WHERE region = p_region_name;

    RAISE NOTICE 'Aplikovaná zľava % pre región %', p_discount_rate, p_region_name;
END;
$$;

CALL apply_regional_discount('West', 0.10);

SELECT SUM(sales) 
FROM orders 
WHERE region = 'West';

-----------------------------------------------------
CREATE OR REPLACE PROCEDURE get_sales_between(
    p_start_date DATE,
    p_end_date DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_sales NUMERIC(12,2);
BEGIN
    SELECT SUM(sales)
    INTO v_total_sales
    FROM orders
    WHERE order_date BETWEEN p_start_date AND p_end_date;

    RAISE NOTICE 'Celkový predaj od % do % je: %', p_start_date, p_end_date, COALESCE(v_total_sales, 0);
END;
$$;


CALL get_sales_between('2024-01-01', '2024-03-31');