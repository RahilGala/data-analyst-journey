-- 1. Find the top 3 customers by total revenue.
SELECT DISTINCT *
FROM
  (SELECT c.customer_id,
          CONCAT(c.first_name, ' ', c.last_name) full_name,
          SUM(oi.quantity * oi.price) OVER(PARTITION BY c.customer_id) total_revenue
   FROM customers c
   JOIN orders o ON o.customer_id = c.customer_id
   JOIN order_items oi ON oi.order_id = o.order_id) customer_revenue
ORDER BY total_revenue DESC
LIMIT 3;

-- 2. Find the top 3 product categories by total revenue.
SELECT
    p.category,
    SUM(oi.quantity * oi.price) AS category_rev
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_rev DESC
LIMIT 3;

-- 3.Find the top 5 products by total revenue and show, for each product: product_id, name, category, product_revenue, and product_revenue as a percentage of its category's total revenue.
WITH product_and_category AS (
    SELECT
        p.product_id,
        p.name,
        p.category,
        COALESCE(SUM(oi.quantity * oi.price), 0) AS revenue_per_product
    FROM products p
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.name, p.category
)
SELECT
    product_id,
    name,
    category,
    revenue_per_product,
    CASE
        WHEN category_rev > 0 THEN (revenue_per_product / category_rev) * 100
        ELSE 0
    END AS pct_of_category
FROM (
    SELECT
        pap.*,
        SUM(pap.revenue_per_product) OVER (PARTITION BY pap.category) AS category_rev
    FROM product_and_category pap
) t
ORDER BY revenue_per_product DESC
LIMIT 5;

-- 4. Build a customer-level summary (one row per customer) showing:
--    customer_id
--    total_spend (sum of quantity*price)
--    order_count
--    avg_order_value (total_spend / order_count)
--    first_order_date
--    last_order_date
--    days_active (difference in days between first and last order)
--    orders_per_30_days (order_count / (days_active/30), handle days_active = 0)

WITH cust_agg AS (
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.price) AS total_spend,
        COUNT(DISTINCT o.order_id) AS order_count,
        MIN(o.order_date) AS first_order_date,
        MAX(o.order_date) AS last_order_date
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT
    customer_id,
    total_spend,
    order_count,
    ROUND(total_spend / NULLIF(order_count, 0), 2) AS avg_order_value,
    first_order_date,
    last_order_date,
    CASE
        WHEN first_order_date IS NULL THEN 0
        ELSE DATEDIFF(last_order_date, first_order_date)
    END AS days_active,
    ROUND(
        order_count / (GREATEST(CASE WHEN first_order_date IS NULL THEN 0 ELSE DATEDIFF(last_order_date, first_order_date) END, 1) / 30.0)
    , 2) AS orders_per_30_days
FROM cust_agg
ORDER BY total_spend DESC;






