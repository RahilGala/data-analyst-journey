create database if not exists day2_sql;
use day2_sql;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50),
    region VARCHAR(50)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO customers VALUES
(1, 'Aisha', 'North'),
(2, 'Mehul', 'South'),
(3, 'Riya', 'East');

INSERT INTO orders VALUES
(101, 1, 1500),
(102, 2, 800),
(103, 1, 2300);

-- Exercise 1
-- Show all customers:
SELECT * FROM customers;

-- Exercise 2
-- Show name + region:
SELECT name, region
FROM customers;

-- Exercise 3
-- Show orders > 1000:
SELECT order_id, amount
FROM orders
WHERE amount > 1000;

-- Exercise 4
-- Show customers from "North":
SELECT *
FROM customers
WHERE region = 'North';

-- Exercise 5
-- Sort orders from highest to lowest:
SELECT *
FROM orders
ORDER BY amount DESC;

-- Exercise 6
-- Top 2 highest orders:
SELECT *
FROM orders
ORDER BY amount DESC
LIMIT 2;

