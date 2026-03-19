-- ============================================================
-- Part 1 — Schema Design (3NF Normalization of orders_flat.csv)
-- ============================================================
-- Tables: customers, products, sales_reps, orders
-- All anomalies from the flat file are eliminated.
-- ============================================================

-- Drop tables if they exist (for clean re-runs)
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS sales_reps;

-- -------------------------
-- Table 1: sales_reps
-- Stores each sales representative exactly once.
-- Eliminates the update anomaly on office_address / rep details.
-- -------------------------
CREATE TABLE sales_reps (
    sales_rep_id   VARCHAR(10)  NOT NULL,
    sales_rep_name VARCHAR(100) NOT NULL,
    sales_rep_email VARCHAR(150) NOT NULL,
    office_address  VARCHAR(200) NOT NULL,
    CONSTRAINT pk_sales_reps PRIMARY KEY (sales_rep_id)
);

INSERT INTO sales_reps (sales_rep_id, sales_rep_name, sales_rep_email, office_address) VALUES
    ('SR01', 'Deepak Joshi', 'deepak@corp.com', 'Mumbai HQ, Nariman Point, Mumbai - 400021'),
    ('SR02', 'Anita Desai',  'anita@corp.com',  'Delhi Office, Connaught Place, New Delhi - 110001'),
    ('SR03', 'Ravi Kumar',   'ravi@corp.com',   'South Zone, MG Road, Bangalore - 560001');

-- -------------------------
-- Table 2: customers
-- Stores each customer exactly once.
-- Eliminates delete anomaly — customer identity survives order deletion.
-- -------------------------
CREATE TABLE customers (
    customer_id    VARCHAR(10)  NOT NULL,
    customer_name  VARCHAR(100) NOT NULL,
    customer_email VARCHAR(150) NOT NULL,
    customer_city  VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT uq_customer_email UNIQUE (customer_email)
);

INSERT INTO customers (customer_id, customer_name, customer_email, customer_city) VALUES
    ('C001', 'Rohan Mehta',  'rohan@gmail.com',  'Mumbai'),
    ('C002', 'Priya Sharma', 'priya@gmail.com',  'Delhi'),
    ('C003', 'Amit Verma',   'amit@gmail.com',   'Bangalore'),
    ('C004', 'Sneha Iyer',   'sneha@gmail.com',  'Chennai'),
    ('C005', 'Vikram Singh', 'vikram@gmail.com', 'Mumbai'),
    ('C006', 'Neha Gupta',   'neha@gmail.com',   'Delhi'),
    ('C007', 'Arjun Nair',   'arjun@gmail.com',  'Bangalore'),
    ('C008', 'Kavya Rao',    'kavya@gmail.com',  'Hyderabad');

-- -------------------------
-- Table 3: products
-- Stores each product exactly once.
-- Eliminates insert anomaly — product can exist without any orders.
-- Eliminates update anomaly — price change requires only one row update.
-- -------------------------
CREATE TABLE products (
    product_id   VARCHAR(10)  NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    category     VARCHAR(50)  NOT NULL,
    unit_price   NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    CONSTRAINT pk_products PRIMARY KEY (product_id)
);

INSERT INTO products (product_id, product_name, category, unit_price) VALUES
    ('P001', 'Laptop',        'Electronics', 55000.00),
    ('P002', 'Mouse',         'Electronics',   800.00),
    ('P003', 'Desk Chair',    'Furniture',    8500.00),
    ('P004', 'Notebook',      'Stationery',    120.00),
    ('P005', 'Headphones',    'Electronics',  3200.00),
    ('P006', 'Standing Desk', 'Furniture',   22000.00),
    ('P007', 'Pen Set',       'Stationery',    250.00),
    ('P008', 'Webcam',        'Electronics',  2100.00);

-- -------------------------
-- Table 4: orders
-- Each row is one order line.
-- Foreign keys enforce referential integrity.
-- -------------------------
CREATE TABLE orders (
    order_id     VARCHAR(10)   NOT NULL,
    customer_id  VARCHAR(10)   NOT NULL,
    product_id   VARCHAR(10)   NOT NULL,
    sales_rep_id VARCHAR(10)   NOT NULL,
    quantity     INT           NOT NULL CHECK (quantity > 0),
    order_date   DATE          NOT NULL,
    CONSTRAINT pk_orders      PRIMARY KEY (order_id),
    CONSTRAINT fk_ord_cust    FOREIGN KEY (customer_id)  REFERENCES customers(customer_id),
    CONSTRAINT fk_ord_prod    FOREIGN KEY (product_id)   REFERENCES products(product_id),
    CONSTRAINT fk_ord_srep    FOREIGN KEY (sales_rep_id) REFERENCES sales_reps(sales_rep_id)
);

INSERT INTO orders (order_id, customer_id, product_id, sales_rep_id, quantity, order_date) VALUES
    ('ORD1027', 'C002', 'P004', 'SR02', 4, '2023-11-02'),
    ('ORD1114', 'C001', 'P007', 'SR01', 2, '2023-08-06'),
    ('ORD1153', 'C006', 'P007', 'SR01', 3, '2023-02-14'),
    ('ORD1002', 'C002', 'P005', 'SR02', 1, '2023-01-17'),
    ('ORD1118', 'C006', 'P007', 'SR02', 5, '2023-11-10'),
    ('ORD1132', 'C003', 'P007', 'SR02', 5, '2023-03-07'),
    ('ORD1037', 'C002', 'P007', 'SR03', 2, '2023-03-06'),
    ('ORD1075', 'C005', 'P003', 'SR03', 3, '2023-04-18'),
    ('ORD1083', 'C006', 'P007', 'SR01', 2, '2023-07-03'),
    ('ORD1091', 'C001', 'P006', 'SR01', 3, '2023-07-24'),
    ('ORD1162', 'C006', 'P004', 'SR03', 3, '2023-09-29'),
    ('ORD1185', 'C003', 'P008', 'SR03', 1, '2023-06-15'),
    ('ORD1076', 'C004', 'P006', 'SR03', 5, '2023-05-16'),
    ('ORD1133', 'C001', 'P004', 'SR03', 1, '2023-10-16'),
    ('ORD1061', 'C006', 'P001', 'SR01', 4, '2023-10-27'),
    ('ORD1098', 'C007', 'P001', 'SR03', 2, '2023-10-03'),
    ('ORD1131', 'C008', 'P001', 'SR02', 4, '2023-06-22'),
    ('ORD1022', 'C005', 'P002', 'SR01', 5, '2023-10-15'),
    ('ORD1054', 'C002', 'P001', 'SR03', 1, '2023-10-04'),
    ('ORD1095', 'C001', 'P001', 'SR03', 3, '2023-08-11');
