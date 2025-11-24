-- 1. Show total revenue per customer.
SELECT
	c.customer_id,
    c.first_name,
    c.last_name,
    SUM(oi.price * oi.quantity) OVER(PARTITION BY c.customer_id,c.first_name,c.last_name) revenue_per_customer
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id;

-- 2. Show order_total for each order plus average order value using AVG() OVER().
SELECT
    oi.order_id,
    SUM(oi.quantity * oi.price) AS order_total,
    AVG(SUM(oi.quantity * oi.price)) OVER () AS avg_order_value
FROM order_items oi
GROUP BY oi.order_id
ORDER BY order_total DESC;

-- 3. Rank each customer's orders by revenue using RANK().
SELECT
    c.customer_id,
    o.order_id,
    SUM(oi.quantity * oi.price) AS order_total,
    SUM(SUM(oi.quantity * oi.price)) 
        OVER (PARTITION BY c.customer_id) AS customer_total_revenue,
    RANK() OVER (
        PARTITION BY c.customer_id
        ORDER BY SUM(oi.quantity * oi.price) DESC
    ) AS order_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, o.order_id
ORDER BY c.customer_id, order_rank;

-- 4. Assign ROW_NUMBER() to each order sorted by order_date.
SELECT
	order_id,
    order_date,
    ROW_NUMBER() OVER(ORDER BY order_date ASC) row_num
FROM orders
ORDER BY order_date ASC;

-- 5. Running total per customer
SELECT
    o.customer_id,
    o.order_id,
    o.order_date,
    SUM(oi.quantity * oi.price) AS order_total,
    SUM(SUM(oi.quantity * oi.price)) OVER (
        PARTITION BY o.customer_id
        ORDER BY o.order_date, o.order_id
    ) AS running_total
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.customer_id, o.order_id, o.order_date
ORDER BY o.customer_id, o.order_date;

-- 6. Find the highest revenue order per customer.
SELECT *
FROM (
    SELECT 
        c.customer_id,
        o.order_id,
        SUM(quantity * price) AS revenue,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id 
            ORDER BY c.customer_id ASC, SUM(quantity * price) DESC
        ) AS rev_order
    FROM customers c
    JOIN orders o 
        ON c.customer_id = o.customer_id
    JOIN order_items oi 
        ON oi.order_id = o.order_id
    GROUP BY c.customer_id, o.order_id
) hro
WHERE rev_order = 1;

-- 7. Find the top selling product per category.
SELECT *
FROM (
    SELECT
        p.product_id,
        p.category,
        SUM(quantity * price) AS rev,
        RANK() OVER (
            PARTITION BY category
            ORDER BY SUM(quantity * price) DESC
        ) AS product_rank
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.product_id,
        category
) rankings
WHERE product_rank = 1;

-- 8. Compare each product’s price with average category price using AVG() OVER(PARTITION BY).
SELECT
    p.product_id,
    p.name,
    p.category,
    p.retail_price,
    AVG(p.retail_price) OVER (PARTITION BY p.category) AS avg_category_price
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    p.product_id
ORDER BY
    p.product_id;

-- 9. Show total quantity sold per product using SUM(quantity) OVER(PARTITION BY).
SELECT DISTINCT
    product_id,
    SUM(quantity) OVER (
        PARTITION BY product_id
        ORDER BY product_id
    ) AS quantity_sold_per_product
FROM order_items;

-- 10. Segment customers as High/Medium/Low using CASE + window total spend.
SELECT DISTINCT
    o.customer_id,
    SUM(oi.quantity * oi.price) OVER (PARTITION BY o.customer_id) AS total_spend,
    CASE
        WHEN SUM(oi.quantity * oi.price) OVER (PARTITION BY o.customer_id) >= 2000 THEN 'High'
        WHEN SUM(oi.quantity * oi.price) OVER (PARTITION BY o.customer_id) BETWEEN 500 AND 1999 THEN 'Medium'
        ELSE 'Low'
    END AS spend_segment
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
ORDER BY total_spend DESC;

