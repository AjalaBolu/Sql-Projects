CREATE TABLE sales (
    row_id          INT PRIMARY KEY,
    order_id        VARCHAR(20)     NOT NULL,
    order_date      DATE            NOT NULL,
    ship_date       DATE,
    ship_mode       VARCHAR(30),
    customer_id     VARCHAR(20)     NOT NULL,
    customer_name   VARCHAR(100),
    segment         VARCHAR(30),
    country         VARCHAR(50),
    city            VARCHAR(50),
    state           VARCHAR(50),
    postal_code     VARCHAR(10),
    region           VARCHAR(20),
    product_id      VARCHAR(20)     NOT NULL,
    category        VARCHAR(30),
    sub_category    VARCHAR(30),
    product_name    VARCHAR(200),
    sales           DECIMAL(10,2)   NOT NULL,
    quantity        INT             NOT NULL,
    discount        DECIMAL(4,2),
    profit          DECIMAL(10,2)
);


CREATE TABLE products (
    product_id      VARCHAR(20) PRIMARY KEY,
    category        VARCHAR(30),
    sub_category    VARCHAR(30),
    product_name    VARCHAR(200)
);

drop table customers;
CREATE TABLE customers (
    customer_id     VARCHAR(20) PRIMARY KEY,
    customer_name   VARCHAR(100),
    segment         VARCHAR(30)
);

CREATE TABLE orders (
    row_id          INT PRIMARY KEY,
    order_id        VARCHAR(20)     NOT NULL,
    order_date      DATE            NOT NULL,
    ship_date       DATE,
    ship_mode       VARCHAR(30),
    customer_id     VARCHAR(20)     REFERENCES customers(customer_id),
    product_id      VARCHAR(20)     REFERENCES products(product_id),
    country         VARCHAR(50),
    city            VARCHAR(50),
    state           VARCHAR(50),
    postal_code     VARCHAR(10),
    region          VARCHAR(20),
    sales           DECIMAL(10,2)   NOT NULL,
    quantity        INT             NOT NULL,
    discount        DECIMAL(4,2),
    profit          DECIMAL(10,2)
);


SELECT COUNT(*) FROM sales;
SELECT COUNT(*) FROM orders;    -- should match sales
SELECT COUNT(*) FROM customers; -- should be less than sales (deduped)
SELECT COUNT(*) FROM products;  -- should be less than sales (deduped)


-- SALES PERFORMANCE ANALYSIS — SQL TASK LIST


-- 1. Total revenue by region

select 
	region,
	sum(sales) as total_revenue
from sales
group by 1;

-- 2. Total profit by region

select 
	region,
	sum(profit) as total_profit
from orders
group by region;

-- 3. Order count by region

select 
	region,
	count(distinct order_id) as order_count
from orders
group by region;

--  4. Top 10 products by profit

select
	p.product_name,
	sum(profit) as total_profit
from orders as o 
join products as p
	on o.product_id = p.product_id
group by 1
order by 2 desc
limit 10;

-- 5. Bottom 10 products by profit

select
	p.product_name,
	sum(profit) as total_profit
from orders as o 
join products as p
	on o.product_id = p.product_id
group by 1
order by 2 asc
limit 10;

-- 6. Products with negative total profit (money-losers)

select *
from (
	select
		p.product_name,
		sum(profit) as total_profit
	from orders as o 
	join products as p
		on o.product_id = p.product_id
	group by 1
	order by 2 asc
) as t1
where total_profit < 0 ;

--  7. Month-over-month sales trend

select 
	DATE_TRUNC('month', order_date) as months,
	sum(sales) as total_revenue
from orders
group by 1
order by 1;

-- 8. Month-over-month profit trend

select 
	DATE_TRUNC('month', order_date) as months,
	sum(profit) as total_profit
from orders
group by 1
order by 1;


--  9. Profit margin by category and sub-category

select 
	p.category,
	p.sub_category,
	sum(o.profit) as total_profit,
	ROUND(SUM(o.profit) / SUM(o.sales) * 100, 2) AS profit_margin_pct
from products as p
left join orders as o
	on p.product_id = o.product_id
group by 1,2
order by 4;

-- [ ] 10. Top 10 customers by total sales

-- [ ] 11. Top 10 customers by total profit

-- [ ] 12. Sales and profit by segment (Consumer / Corporate / Home Office)

-- [ ] 13. Average discount vs. profit margin (does heavy discounting hurt profit?)

-- [ ] 14. Ship mode breakdown — order count and average delivery time (ship_date - order_date)

-- [ ] 15. Year-over-year revenue growth

-- ============================================================

/*
-- ============================================================
-- SALES PERFORMANCE ANALYSIS PROJECT
-- Dataset: Sample Superstore (Kaggle)
-- https://www.kaggle.com/datasets/vivek468/superstore-dataset-final
-- ============================================================
-- This script:
--   1. Loads the raw CSV into a flat staging table
--   2. Splits it into normalized customers / products / orders tables
--   3. Handles real data-quality issues found in this dataset
--      (duplicate customer/product IDs with conflicting details)
-- ============================================================


-- ------------------------------------------------------------
-- STEP 1: Create a staging table matching the raw CSV columns
-- ------------------------------------------------------------
CREATE TABLE sales (
    row_id          INT,
    order_id        VARCHAR(20),
    order_date      DATE,
    ship_date       DATE,
    ship_mode       VARCHAR(30),
    customer_id     VARCHAR(20),
    customer_name   VARCHAR(100),
    segment         VARCHAR(30),
    country         VARCHAR(50),
    city            VARCHAR(50),
    state           VARCHAR(50),
    postal_code     VARCHAR(10),
    region          VARCHAR(20),
    product_id      VARCHAR(20),
    category        VARCHAR(30),
    sub_category    VARCHAR(30),
    product_name    VARCHAR(200),
    sales           DECIMAL(10,2),
    quantity        INT,
    discount        DECIMAL(4,2),
    profit          DECIMAL(10,2)
);

-- ------------------------------------------------------------
-- STEP 2: Load the CSV into the staging table
-- ------------------------------------------------------------
-- Use \copy (client-side) instead of COPY (server-side) to avoid
-- Windows file-permission errors, since \copy reads the file as
-- your own user rather than the Postgres service account.
--
-- ENCODING 'LATIN1' handles the 0xA0 (non-breaking space) byte
-- that commonly shows up in Excel/Windows-exported CSVs and
-- breaks a plain UTF8 import.
--
-- Update the file path below to match your own machine.

\copy sales FROM 'C:\projects\SQL\SQL PROJECTS\Sales Performane analysis\Sample - Superstore.csv' WITH (FORMAT csv, HEADER true, ENCODING 'LATIN1')


-- ------------------------------------------------------------
-- STEP 3: Check for data quality issues before normalizing
-- ------------------------------------------------------------
-- This dataset has customer_ids and product_ids that repeat with
-- CONFLICTING details (e.g. the same customer_id shipping to two
-- different cities/states). A plain DISTINCT insert will violate
-- the primary key in that case, so check first.

-- Customers: does the same customer_id have multiple names/cities/states?
SELECT customer_id, COUNT(DISTINCT customer_name) AS name_variants,
       COUNT(DISTINCT city) AS city_variants,
       COUNT(DISTINCT state) AS state_variants
FROM sales
GROUP BY customer_id
HAVING COUNT(DISTINCT customer_name) > 1
    OR COUNT(DISTINCT city) > 1
    OR COUNT(DISTINCT state) > 1;

-- Products: does the same product_id have multiple category/name variants?
SELECT product_id, COUNT(DISTINCT category) AS category_variants,
       COUNT(DISTINCT sub_category) AS sub_category_variants,
       COUNT(DISTINCT product_name) AS name_variants
FROM sales
GROUP BY product_id
HAVING COUNT(DISTINCT category) > 1
    OR COUNT(DISTINCT sub_category) > 1
    OR COUNT(DISTINCT product_name) > 1;

-- Finding: city/state DO vary per customer_id (e.g. AA-10315 "Alex Avila"
-- ships to both Minneapolis, MN and San Francisco, CA). This means
-- city/state/postal_code/region are really SHIPPING details tied to
-- each ORDER, not fixed attributes of the customer. So those fields
-- are modeled on the orders table below, not on customers.


-- ------------------------------------------------------------
-- STEP 4: Create the normalized tables
-- ------------------------------------------------------------
CREATE TABLE customers (
    customer_id     VARCHAR(20) PRIMARY KEY,
    customer_name   VARCHAR(100),
    segment         VARCHAR(30)
);

CREATE TABLE products (
    product_id      VARCHAR(20) PRIMARY KEY,
    category        VARCHAR(30),
    sub_category    VARCHAR(30),
    product_name    VARCHAR(200)
);

CREATE TABLE orders (
    row_id          INT PRIMARY KEY,
    order_id        VARCHAR(20)     NOT NULL,
    order_date      DATE            NOT NULL,
    ship_date       DATE,
    ship_mode       VARCHAR(30),
    customer_id     VARCHAR(20)     REFERENCES customers(customer_id),
    product_id      VARCHAR(20)     REFERENCES products(product_id),
    country         VARCHAR(50),
    city            VARCHAR(50),
    state           VARCHAR(50),
    postal_code     VARCHAR(10),
    region          VARCHAR(20),
    sales           DECIMAL(10,2)   NOT NULL,
    quantity        INT             NOT NULL,
    discount        DECIMAL(4,2),
    profit          DECIMAL(10,2)
);


-- ------------------------------------------------------------
-- STEP 5: Populate customers and products
-- ------------------------------------------------------------
-- Use ROW_NUMBER() instead of plain DISTINCT so that IDs with
-- conflicting details still resolve to ONE canonical row each
-- (the first occurrence by row_id), avoiding primary key errors.

INSERT INTO customers (customer_id, customer_name, segment)
SELECT customer_id, customer_name, segment
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY row_id) AS rn
    FROM sales
) t
WHERE rn = 1;

INSERT INTO products (product_id, category, sub_category, product_name)
SELECT product_id, category, sub_category, product_name
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY row_id) AS rn
    FROM sales
) t
WHERE rn = 1;


-- ------------------------------------------------------------
-- STEP 6: Populate orders (the transactional fact table)
-- ------------------------------------------------------------
-- Populate this AFTER customers and products, since it has
-- foreign keys pointing to both.

INSERT INTO orders (row_id, order_id, order_date, ship_date, ship_mode, customer_id, product_id,
                     country, city, state, postal_code, region, sales, quantity, discount, profit)
SELECT row_id, order_id, order_date, ship_date, ship_mode, customer_id, product_id,
       country, city, state, postal_code, region, sales, quantity, discount, profit
FROM sales;


-- ------------------------------------------------------------
-- STEP 7: Sanity checks
-- ------------------------------------------------------------
SELECT COUNT(*) FROM sales;      -- baseline row count
SELECT COUNT(*) FROM orders;     -- should match sales
SELECT COUNT(*) FROM customers;  -- should be less than sales (deduped)
SELECT COUNT(*) FROM products;   -- should be less than sales (deduped)

-- If a TRUNCATE is ever needed to redo products/orders, truncate
-- both together since orders has a foreign key into products:
-- TRUNCATE TABLE orders, products;

*/