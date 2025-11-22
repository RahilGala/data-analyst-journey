USE retail_db;

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(oi.quantity * oi.price) AS total_spend
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING total_spend >
    (SELECT 
        AVG(customer_spend)
     FROM (
        SELECT 
            SUM(oi2.quantity * oi2.price) AS customer_spend
        FROM orders o2
        JOIN order_items oi2 ON o2.order_id = oi2.order_id
        GROUP BY o2.customer_id
     ) AS avg_table);
     
SELECT
    p.product_id,
    p.name,
    p.category,
    p.retail_price,
    (SELECT AVG(retail_price)
     FROM products p2
     WHERE p2.category = p.category) AS category_avg_price
FROM products p;

SELECT *
FROM (
    SELECT 
        o.order_id,
        SUM(oi.quantity * oi.price) AS order_total
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id	
) AS t
WHERE t.order_total > 2000;

-- 1. Find customers who spent more than the average customer spend.
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(oi.quantity * oi.price) AS total_spend
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(oi.quantity * oi.price) >
    (
        SELECT AVG(customer_total) FROM (
            SELECT SUM(oi2.quantity * oi2.price) AS customer_total
            FROM orders o2
            JOIN order_items oi2 ON o2.order_id = oi2.order_id
            GROUP BY o2.customer_id
        ) AS t
    );

-- 2. Find orders with total > average order value.
SELECT 
    o.order_id,
    SUM(oi.quantity * oi.price) AS order_total
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_id
HAVING SUM(oi.quantity * oi.price) >
    (
        SELECT AVG(order_total) FROM (
            SELECT SUM(oi2.quantity * oi2.price) AS order_total
            FROM orders o2
            JOIN order_items oi2 ON o2.order_id = oi2.order_id
            GROUP BY o2.order_id
        ) AS avg_table
    )
ORDER BY order_total DESC;

-- 3. Find products priced above their category average.
SELECT 
    p.product_id,
    p.name,
    p.category,
    p.retail_price,
    cat.category_avg
FROM products p
JOIN (
    SELECT category, AVG(retail_price) AS category_avg
    FROM products
    GROUP BY category
) AS cat ON p.category = cat.category
WHERE p.retail_price > cat.category_avg
ORDER BY p.category, p.retail_price DESC;

-- 4. Find customers who placed more orders than the average order count.
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS orders_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) >
    (
        SELECT AVG(order_count) FROM (
            SELECT COUNT(o2.order_id) AS order_count
            FROM orders o2
            GROUP BY o2.customer_id
        ) AS t
    )
ORDER BY orders_count DESC;

-- 5. Find products never purchased (using NOT IN).
SELECT
    p.product_id,
    p.name,
    p.category,
    p.retail_price
FROM products p
WHERE p.product_id NOT IN (
    SELECT DISTINCT oi.product_id FROM order_items oi
);

-- 6. Top 3 categories by revenue.
SELECT
    p.category,
    SUM(oi.quantity * oi.price) AS category_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_revenue DESC
LIMIT 3;

-- 7. Highest revenue order per customer.
SELECT
    customer_id,
    order_id,
    order_total
FROM (
    SELECT
        o.customer_id,
        o.order_id,
        SUM(oi.quantity * oi.price) AS order_total,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY SUM(oi.quantity * oi.price) DESC) AS rn
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id, o.order_id
) t
WHERE rn = 1
ORDER BY customer_id;

-- 8. Customer with max lifetime spend.
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(oi.quantity * oi.price) AS lifetime_spend
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY lifetime_spend DESC
LIMIT 1;

-- 9. Cities with above-average revenue.
SELECT
    c.city,
    SUM(oi.quantity * oi.price) AS city_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.city
HAVING SUM(oi.quantity * oi.price) >
    (
        SELECT AVG(city_rev) FROM (
            SELECT SUM(oi2.quantity * oi2.price) AS city_rev
            FROM customers c2
            JOIN orders o2 ON c2.customer_id = o2.customer_id
            JOIN order_items oi2 ON o2.order_id = oi2.order_id
            GROUP BY c2.city
        ) AS t
    )
ORDER BY city_revenue DESC;

-- 10. For each product, mark "High Demand" if total quantity sold is above category average.
SELECT
    p.product_id,
    p.name,
    p.category,
    SUM(oi.quantity) AS total_quantity,
    CASE
        WHEN SUM(oi.quantity) > (
            SELECT AVG(prod_qty) FROM (
                SELECT p2.category, SUM(oi2.quantity) AS prod_qty
                FROM products p2
                LEFT JOIN order_items oi2 ON p2.product_id = oi2.product_id
                WHERE p2.category = p.category
                GROUP BY p2.product_id
            ) AS cat_avg
        ) THEN 'High Demand'
        ELSE 'Normal Demand'
    END AS demand_flag
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name, p.category
ORDER BY p.category, total_quantity DESC;

-- 11. Categorize customers as "High", "Medium", "Low" based on total spend.
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COALESCE(SUM(oi.quantity * oi.price),0) AS total_spend,
    CASE
        WHEN COALESCE(SUM(oi.quantity * oi.price),0) >= 2000 THEN 'High'
        WHEN COALESCE(SUM(oi.quantity * oi.price),0) BETWEEN 500 AND 1999 THEN 'Medium'
        ELSE 'Low'
    END AS spend_category
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spend DESC;

-- 12. Flag high-value orders (above 2000).
SELECT
    o.order_id,
    SUM(oi.quantity * oi.price) AS order_total,
    CASE
        WHEN SUM(oi.quantity * oi.price) > 2000 THEN 'High Value'
        ELSE 'Regular'
    END AS order_type
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id
ORDER BY order_total DESC;

-- 13. Categorize products as "Cheap", "Mid", "Premium".
SELECT
    product_id,
    name,
    retail_price,
    CASE
        WHEN retail_price >= 2000 THEN 'Premium'
        WHEN retail_price BETWEEN 500 AND 1999 THEN 'Mid'
        ELSE 'Cheap'
    END AS price_segment
FROM products
ORDER BY retail_price DESC;

-- 14. Bucket revenue into ranges (<500, 500-2000, >2000) for each order.
SELECT
    o.order_id,
    SUM(oi.quantity * oi.price) AS order_total,
    CASE
        WHEN SUM(oi.quantity * oi.price) < 500 THEN '<500'
        WHEN SUM(oi.quantity * oi.price) BETWEEN 500 AND 2000 THEN '500-2000'
        ELSE '>2000'
    END AS revenue_bucket
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id
ORDER BY order_total DESC;

-- 15. Flag repeat customers (more than 1 order).
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS orders_count,
    CASE
        WHEN COUNT(o.order_id) > 1 THEN 'Repeat'
        ELSE 'One-time'
    END AS customer_type
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY orders_count DESC;

-- 16. Normalize order status into Delivered / Pending / Cancelled / Other.
SELECT
    order_id,
    status,
    CASE
        WHEN LOWER(status) LIKE '%deliv%' THEN 'Delivered'
        WHEN LOWER(status) LIKE '%pend%' THEN 'Pending'
        WHEN LOWER(status) LIKE '%cancel%' THEN 'Cancelled'
        ELSE 'Other'
    END AS normalized_status
FROM orders;

-- 17. Create field "Expensive?" yes/no based on retail_price > 1000.
SELECT
    product_id,
    name,
    retail_price,
    CASE
        WHEN retail_price > 1000 THEN 'Yes'
        ELSE 'No'
    END AS expensive_flag
FROM products
ORDER BY retail_price DESC;

-- 18. Category-wise segmentation using CASE (High Ticket vs Low Ticket).
SELECT
    product_id,
    name,
    category,
    retail_price,
    CASE
        WHEN category IN ('Electronics','Furniture') THEN 'High Ticket'
        ELSE 'Low Ticket'
    END AS category_segment
FROM products;

-- 19. Flag cities as North/West/South/East (manual mapping).
SELECT
    customer_id,
    first_name,
    last_name,
    city,
    CASE
        WHEN city IN ('Delhi','Jaipur') THEN 'North'
        WHEN city IN ('Mumbai','Surat','Pune','Ahmedabad') THEN 'West'
        WHEN city IN ('Bangalore','Hyderabad','Chennai') THEN 'South'
        WHEN city IN ('Kolkata') THEN 'East'
        ELSE 'Unknown'
    END AS region_label
FROM customers;

-- 20. Mark customers with NULL or empty email as "missing_email".
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    CASE
        WHEN email IS NULL OR TRIM(email) = '' THEN 'missing_email'
        ELSE 'has_email'
    END AS email_status
FROM customers;


