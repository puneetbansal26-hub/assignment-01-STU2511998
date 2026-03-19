-- ============================================================
-- Part 3 — Star Schema Design (star_schema.sql)
-- Source: retail_transactions.csv
-- ============================================================
-- Data issues found in source:
--   1. Inconsistent date formats: YYYY-MM-DD, DD/MM/YYYY, DD-MM-YYYY
--   2. Inconsistent category casing: 'electronics', 'Electronics', 'Grocery', 'Groceries'
--   3. No explicit NULL rows, but category values are non-standard
-- All cleaned data is reflected in INSERT statements below.
-- ============================================================

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_store;
DROP TABLE IF EXISTS dim_product;

-- -------------------------
-- Dimension 1: dim_date
-- -------------------------
CREATE TABLE dim_date (
    date_key      INT          NOT NULL,   -- YYYYMMDD integer surrogate key
    full_date     DATE         NOT NULL,
    day_of_month  INT          NOT NULL,
    month_num     INT          NOT NULL,
    month_name    VARCHAR(15)  NOT NULL,
    quarter       INT          NOT NULL,
    year          INT          NOT NULL,
    CONSTRAINT pk_dim_date PRIMARY KEY (date_key)
);

INSERT INTO dim_date (date_key, full_date, day_of_month, month_num, month_name, quarter, year) VALUES
    (20230105, '2023-01-05', 5,  1, 'January',  1, 2023),
    (20230215, '2023-02-15', 15, 2, 'February', 1, 2023),
    (20230320, '2023-03-20', 20, 3, 'March',    1, 2023),
    (20230418, '2023-04-18', 18, 4, 'April',    2, 2023),
    (20230510, '2023-05-10', 10, 5, 'May',      2, 2023),
    (20230612, '2023-06-12', 12, 6, 'June',     2, 2023),
    (20230714, '2023-07-14', 14, 7, 'July',     3, 2023),
    (20230822, '2023-08-22', 22, 8, 'August',   3, 2023),
    (20230905, '2023-09-05', 5,  9, 'September',3, 2023),
    (20231010, '2023-10-10', 10,10, 'October',  4, 2023),
    (20231115, '2023-11-15', 15,11, 'November', 4, 2023),
    (20231208, '2023-12-08', 8, 12, 'December', 4, 2023);

-- -------------------------
-- Dimension 2: dim_store
-- -------------------------
CREATE TABLE dim_store (
    store_key   SERIAL       NOT NULL,
    store_name  VARCHAR(100) NOT NULL,
    store_city  VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_dim_store PRIMARY KEY (store_key)
);

INSERT INTO dim_store (store_key, store_name, store_city) VALUES
    (1, 'Chennai Anna',  'Chennai'),
    (2, 'Delhi South',   'Delhi'),
    (3, 'Mumbai Central','Mumbai'),
    (4, 'Bangalore MG',  'Bangalore'),
    (5, 'Pune FC Road',  'Pune');

-- -------------------------
-- Dimension 3: dim_product
-- -------------------------
CREATE TABLE dim_product (
    product_key   SERIAL       NOT NULL,
    product_name  VARCHAR(100) NOT NULL,
    category      VARCHAR(50)  NOT NULL,   -- standardized
    CONSTRAINT pk_dim_product PRIMARY KEY (product_key)
);

-- Categories standardized: 'Electronics', 'Clothing', 'Grocery'
INSERT INTO dim_product (product_key, product_name, category) VALUES
    (1,  'Laptop',      'Electronics'),
    (2,  'Phone',       'Electronics'),
    (3,  'Tablet',      'Electronics'),
    (4,  'Headphones',  'Electronics'),
    (5,  'Smartwatch',  'Electronics'),
    (6,  'Speaker',     'Electronics'),
    (7,  'Jeans',       'Clothing'),
    (8,  'T-Shirt',     'Clothing'),
    (9,  'Saree',       'Clothing'),
    (10, 'Jacket',      'Clothing'),
    (11, 'Rice 5kg',    'Grocery'),
    (12, 'Atta 10kg',   'Grocery'),
    (13, 'Milk 1L',     'Grocery'),
    (14, 'Biscuits',    'Grocery'),
    (15, 'Pulses 1kg',  'Grocery'),
    (16, 'Oil 1L',      'Grocery');

-- -------------------------
-- Fact Table: fact_sales
-- -------------------------
CREATE TABLE fact_sales (
    sale_id          SERIAL        NOT NULL,
    transaction_id   VARCHAR(20)   NOT NULL,
    date_key         INT           NOT NULL,
    store_key        INT           NOT NULL,
    product_key      INT           NOT NULL,
    customer_id      VARCHAR(20),
    units_sold       INT           NOT NULL CHECK (units_sold > 0),
    unit_price       NUMERIC(12,2) NOT NULL CHECK (unit_price > 0),
    total_revenue    NUMERIC(14,2) NOT NULL,  -- units_sold * unit_price (derived/stored)
    CONSTRAINT pk_fact_sales    PRIMARY KEY (sale_id),
    CONSTRAINT fk_fs_date       FOREIGN KEY (date_key)    REFERENCES dim_date(date_key),
    CONSTRAINT fk_fs_store      FOREIGN KEY (store_key)   REFERENCES dim_store(store_key),
    CONSTRAINT fk_fs_product    FOREIGN KEY (product_key) REFERENCES dim_product(product_key)
);

-- 10+ cleaned fact rows
-- Dates normalized to YYYY-MM-DD; categories standardized; all amounts verified
INSERT INTO fact_sales (transaction_id, date_key, store_key, product_key, customer_id, units_sold, unit_price, total_revenue) VALUES
    ('TXN5000', 20230822, 1,  6,  'CUST045', 3,  49262.78, 147788.34),  -- Speaker, Chennai Anna
    ('TXN5001', 20231208, 1,  3,  'CUST021', 11, 23226.12, 255487.32),  -- Tablet, Chennai Anna
    ('TXN5002', 20230215, 1,  2,  'CUST019', 20, 48703.39, 974067.80),  -- Phone, Chennai Anna
    ('TXN5003', 20230320, 2,  3,  'CUST007', 14, 23226.12, 325165.68),  -- Tablet, Delhi South
    ('TXN5004', 20230105, 2,  1,  'CUST033', 5,  75000.00, 375000.00),  -- Laptop, Delhi South
    ('TXN5005', 20230418, 3,  7,  'CUST012', 8,  1999.00,  15992.00),   -- Jeans, Mumbai Central
    ('TXN5006', 20230510, 4,  11, 'CUST028', 20, 299.00,   5980.00),    -- Rice 5kg, Bangalore MG
    ('TXN5007', 20230612, 4,  8,  'CUST041', 15, 799.00,   11985.00),   -- T-Shirt, Bangalore MG
    ('TXN5008', 20230714, 5,  12, 'CUST015', 10, 485.00,   4850.00),    -- Atta 10kg, Pune FC Road
    ('TXN5009', 20230905, 5,  4,  'CUST009', 3,  2499.00,  7497.00),    -- Headphones, Pune FC Road
    ('TXN5010', 20231010, 2,  5,  'CUST037', 6,  15999.00, 95994.00),   -- Smartwatch, Delhi South
    ('TXN5011', 20231115, 3,  13, 'CUST003', 50, 55.00,    2750.00),    -- Milk 1L, Mumbai Central
    ('TXN5012', 20230320, 1,  9,  'CUST022', 4,  3500.00,  14000.00),   -- Saree, Chennai Anna
    ('TXN5013', 20230822, 2,  10, 'CUST056', 7,  2999.00,  20993.00);   -- Jacket, Delhi South
