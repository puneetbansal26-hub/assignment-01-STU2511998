-- ============================================================
-- Part 1 — SQL Queries (queries.sql)
-- All queries run on the normalized schema from schema_design.sql
-- ============================================================

-- Q1: List all customers from Mumbai along with their total order value
SELECT
    c.customer_id,
    c.customer_name,
    c.customer_city,
    SUM(p.unit_price * o.quantity) AS total_order_value
FROM customers c
JOIN orders o    ON c.customer_id  = o.customer_id
JOIN products p  ON o.product_id   = p.product_id
WHERE c.customer_city = 'Mumbai'
GROUP BY c.customer_id, c.customer_name, c.customer_city
ORDER BY total_order_value DESC;

-- Q2: Find the top 3 products by total quantity sold
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(o.quantity) AS total_quantity_sold
FROM products p
JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_quantity_sold DESC
LIMIT 3;

-- Q3: List all sales representatives and the number of unique customers they have handled
SELECT
    sr.sales_rep_id,
    sr.sales_rep_name,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM sales_reps sr
LEFT JOIN orders o ON sr.sales_rep_id = o.sales_rep_id
GROUP BY sr.sales_rep_id, sr.sales_rep_name
ORDER BY unique_customers DESC;

-- Q4: Find all orders where the total value exceeds 10,000, sorted by value descending
SELECT
    o.order_id,
    c.customer_name,
    p.product_name,
    o.quantity,
    p.unit_price,
    (o.quantity * p.unit_price) AS total_order_value,
    o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products  p ON o.product_id  = p.product_id
WHERE (o.quantity * p.unit_price) > 10000
ORDER BY total_order_value DESC;

-- Q5: Identify any products that have never been ordered
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
WHERE o.order_id IS NULL;
