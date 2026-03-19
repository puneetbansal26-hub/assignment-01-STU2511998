-- ============================================================
-- Part 3 — Analytical Queries (dw_queries.sql)
-- All queries run on the star schema from star_schema.sql
-- ============================================================

-- Q1: Total sales revenue by product category for each month
SELECT
    dd.year,
    dd.month_num,
    dd.month_name,
    dp.category,
    SUM(fs.total_revenue)              AS total_revenue,
    SUM(fs.units_sold)                 AS total_units_sold,
    COUNT(DISTINCT fs.transaction_id)  AS num_transactions
FROM fact_sales fs
JOIN dim_date    dd ON fs.date_key    = dd.date_key
JOIN dim_product dp ON fs.product_key = dp.product_key
GROUP BY dd.year, dd.month_num, dd.month_name, dp.category
ORDER BY dd.year, dd.month_num, dp.category;

-- Q2: Top 2 performing stores by total revenue
SELECT
    ds.store_name,
    ds.store_city,
    SUM(fs.total_revenue)             AS total_revenue,
    SUM(fs.units_sold)                AS total_units_sold,
    COUNT(DISTINCT fs.transaction_id) AS num_transactions
FROM fact_sales fs
JOIN dim_store ds ON fs.store_key = ds.store_key
GROUP BY ds.store_key, ds.store_name, ds.store_city
ORDER BY total_revenue DESC
LIMIT 2;

-- Q3: Month-over-month sales trend across all stores
SELECT
    dd.year,
    dd.month_num,
    dd.month_name,
    SUM(fs.total_revenue)                                              AS monthly_revenue,
    SUM(fs.total_revenue)
        - LAG(SUM(fs.total_revenue)) OVER (ORDER BY dd.year, dd.month_num)
                                                                       AS revenue_change,
    ROUND(
        100.0 * (
            SUM(fs.total_revenue)
            - LAG(SUM(fs.total_revenue)) OVER (ORDER BY dd.year, dd.month_num)
        ) / NULLIF(
            LAG(SUM(fs.total_revenue)) OVER (ORDER BY dd.year, dd.month_num), 0
        ), 2
    )                                                                  AS pct_change
FROM fact_sales fs
JOIN dim_date dd ON fs.date_key = dd.date_key
GROUP BY dd.year, dd.month_num, dd.month_name
ORDER BY dd.year, dd.month_num;
