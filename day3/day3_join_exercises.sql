USE retail_db;

SELECT * FROM orders;
SELECT * FROM order_items;

SELECT *
FROM orders o
JOIN order_items oi
	ON o.order_id = oi.order_id;
    
SELECT 
    o.order_id,
    o.order_date,
    c.first_name,
    c.last_name
FROM orders o
INNER JOIN customers c 
    ON o.customer_id = c.customer_id;

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    o.order_id,
    o.order_date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;

SELECT 
    o.order_id,
    o.customer_id,
    c.first_name,
    c.last_name
FROM orders o
RIGHT JOIN customers c
    ON o.customer_id = c.customer_id;

SELECT 
    o.order_id,
    o.order_date,
    c.first_name,
    p.name AS product_name,
    oi.quantity,
    oi.price
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id;


-- Exercices
-- 1. Show all orders with customer name and city.
SELECT 
	o.order_id,
	o.order_date,
    c.first_name,
    c.last_name,
    c.city
FROM orders o
JOIN customers c
	ON o.customer_id = c.customer_id;

-- 2. Show all customers and their order IDs.
SELECT
	c.customer_id,
    c.first_name,
    c.last_name,
    o.order_id
FROM orders o
LEFT JOIN customers c
	ON o.customer_id = c.customer_id;
    
-- 3. Show each order with the products purchased.
SELECT 
	oi.order_id,
    p.name product_name,
    oi.product_id,
    p.retail_price
FROM order_items oi
JOIN products p
	ON oi.product_id = p.product_id;
    
-- 4. Show all order items with the customers who bought them.
SELECT
	c.first_name,
    oi.product_id,
    p.name,
    oi.quantity,
    oi.price
FROM order_items oi
JOIN products p
	ON oi.product_id = p.product_id
JOIN orders o
	ON oi.order_id = o.order_id
JOIN customers c
	ON o.customer_id = c.customer_id;
    
-- 5.Find customers who placed NO orders.
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city,
    c.country
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 6.Show total number of items bought in each order.
SELECT 
    o.order_id,
    SUM(oi.quantity) AS total_items
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_id;

-- 7.Show total revenue for each order.
SELECT 
    o.order_id,
    SUM(oi.quantity * oi.price) AS order_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_id
ORDER BY order_revenue DESC;

-- 8.Show all products that have never been purchased.
SELECT 
    p.product_id,
    p.name,
    p.category,
    p.retail_price
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;

-- 9.Find each customer’s total spend across all orders.
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(oi.quantity * oi.price) AS total_spend
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spend DESC;

-- 10.Show the top 5 highest-revenue orders.
SELECT 
    o.order_id,
    SUM(oi.quantity * oi.price) AS order_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_id
ORDER BY order_revenue DESC
LIMIT 5;