USE retail_db;

-- total orders per customer
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c
	ON o.customer_id = c.customer_id
GROUP BY customer_id;

-- total revenue per order
SELECT
	order_id,
    SUM(quantity*price) revenue
FROM order_items
GROUP BY order_id
ORDER BY revenue DESC;

-- total revenue per customer
SELECT
	c.customer_id,
    c.first_name,
    SUM(oi.quantity * oi.price) as revenue
FROM order_items oi
JOIN orders o
	ON oi.order_id = o.order_id
JOIN customers c
	ON o.customer_id = c.customer_id
GROUP BY c.customer_id;


-- 1. Show number of orders placed by each customer.
SELECT
c.customer_id,
c.first_name,
c.last_name,
COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- 2. Show total revenue per product.
SELECT
p.product_id,
p.name,
SUM(oi.quantity * oi.price) AS total_revenue
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name
ORDER BY total_revenue DESC;

-- 3. Show total quantity sold for each product.
SELECT
p.product_id,
p.name,
SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name
ORDER BY total_quantity_sold DESC;

-- 4. Show revenue per product category.
SELECT
p.category,
SUM(oi.quantity * oi.price) AS category_revenue
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- 5. Show average order value (AOV) for each customer.
SELECT
c.customer_id,
c.first_name,
c.last_name,
AVG(order_totals.order_total) AS avg_order_value
FROM customers c
JOIN (
SELECT
o.order_id,
o.customer_id,
SUM(oi.quantity * oi.price) AS order_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.customer_id
) AS order_totals
ON c.customer_id = order_totals.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY avg_order_value DESC;

-- 6. Show the top 5 customers by total spend.
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
ORDER BY total_spend DESC
LIMIT 5;

-- 7. Show the number of orders per order status.
SELECT
status,
COUNT(*) AS num_orders
FROM orders
GROUP BY status
ORDER BY num_orders DESC;

-- 8. Show the total revenue by city (customer city).
SELECT
c.city,
SUM(oi.quantity * oi.price) AS city_revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.city
ORDER BY city_revenue DESC;

-- 9. Show total orders per day (group by order_date).
SELECT
order_date,
COUNT(*) AS orders_count
FROM orders
GROUP BY order_date
ORDER BY order_date;

-- 10. Show category with the highest number of items sold.
SELECT
p.category,
SUM(oi.quantity) AS total_items_sold
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_items_sold DESC
LIMIT 1;
