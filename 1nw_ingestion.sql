-- CREATE DATABASE northwind_elt;

CREATE SCHEMA IF NOT EXISTS bronze;

\set ON_ERROR_STOP on
\encoding UTF8

CREATE TABLE IF NOT EXISTS bronze.categories (
    categoryid INT,
    categoryname TEXT,
    description TEXT,
    _source_file TEXT DEFAULT 'categories.csv',
    _loaded_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.customers (
    customerid INT,
    customername TEXT,
    contactname TEXT,
    address TEXT,
    city TEXT,
    postalcode TEXT,
    country TEXT,
    _source_file TEXT DEFAULT 'customers.csv',
    _loaded_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.employees (
    employeeid INT,
    lastname TEXT,
    firstname TEXT,
    birthdate TIMESTAMP,
    photo TEXT,
    notes TEXT,
    _source_file TEXT DEFAULT 'employees.csv',
    _loaded_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.suppliers (
    supplierid INT,
    suppliername TEXT,
    contactname TEXT,
    address TEXT,
    city TEXT,
    postalcode TEXT,
    country TEXT,
    phone TEXT,
    _source_file TEXT DEFAULT 'suppliers.csv',
    _loaded_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.shippers (
    shipperid INT,
    shippername TEXT,
    phone TEXT,
    _source_file TEXT DEFAULT 'shippers.csv',
    _loaded_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.products (
    productid INT,
    productname TEXT,
    supplierid INT,
    categoryid INT,
    unit TEXT,
    price NUMERIC(10,2),
    _source_file TEXT DEFAULT 'products.csv',
    _loaded_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.orders (
    orderid INT,
    customerid INT,
    employeeid INT,
    orderdate TIMESTAMP,
    shipperid INT,
    _source_file TEXT DEFAULT 'orders.csv',
    _loaded_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bronze.orderdetails (
    orderdetailid INT,
    orderid INT,
    productid INT,
    quantity INT,
    _source_file TEXT DEFAULT 'orderdetails.csv',
    _loaded_at TIMESTAMP DEFAULT now()
);

BEGIN;

TRUNCATE bronze.categories,
    bronze.customers,
    bronze.employees,
    bronze.suppliers,
    bronze.shippers,
    bronze.products,
    bronze.orders,
    bronze.orderdetails;

\COPY bronze.categories(categoryid, categoryname, description) FROM 'data/Northwind/categories.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';')
\COPY bronze.customers(customerid, customername, contactname, address, city, postalcode, country) FROM 'data/Northwind/customers.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';')
\COPY bronze.employees(employeeid, lastname, firstname, birthdate, photo, notes) FROM 'data/Northwind/employees.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';')
\COPY bronze.suppliers(supplierid, suppliername, contactname, address, city, postalcode, country, phone) FROM 'data/Northwind/suppliers.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';')
\COPY bronze.shippers(shipperid, shippername, phone) FROM 'data/Northwind/shippers.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';')
\COPY bronze.products(productid, productname, supplierid, categoryid, unit, price) FROM 'data/Northwind/products.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';')
\COPY bronze.orders(orderid, customerid, employeeid, orderdate, shipperid) FROM 'data/Northwind/orders.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';')
\COPY bronze.orderdetails(orderdetailid, orderid, productid, quantity) FROM 'data/Northwind/orderdetails.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';')

COMMIT;