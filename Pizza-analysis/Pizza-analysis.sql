CREATE TABLE pizza_sales (
    pizza_id            INTEGER PRIMARY KEY,
    order_id            INTEGER NOT NULL,
    pizza_name_id       VARCHAR(50) NOT NULL,
    quantity            INTEGER NOT NULL,
    order_date          DATE NOT NULL,
    order_time          TIME NOT NULL,
    unit_price          NUMERIC(10,2) NOT NULL,
    total_price         NUMERIC(10,2) NOT NULL,
    pizza_size          VARCHAR(5) NOT NULL,
    pizza_category      VARCHAR(20) NOT NULL,
    pizza_ingredients   TEXT NOT NULL,
    pizza_name          VARCHAR(100) NOT NULL
);

COPY pizza_sales
FROM 'C:\Dev\sandbox\datasets\pizza_sales.csv'
DELIMITER ','
CSV HEADER;


select *
from pizza_sales;

ALTER TABLE pizza_sales RENAME TO pizza;

-- TASKS:
-- 1. What is the total revenue for all pizzas 

select 
	sum(total_price) as total_revenue
from pizza

-- 2. Average order value 
select
	sum(total_price) / count( distinct order_id ) as avg_order
from pizza;

-- 3. Total amount of quantites of pizza's sold
select 
	sum(quantity) as total_pizza_sold
from pizza;

-- 4. Total orders placed
select 
	count(distinct order_id) as total_distinct_orders
from pizza;

-- 5. Avg Pizza per orders
select 
	round(sum(quantity)::numeric / count(distinct order_id),2) as avg_pperorder
from pizza;

-- 6. Daily trend by week 
SELECT 
    TO_CHAR(order_date, 'Day') AS dow,
	count(distinct order_id) as total_sales
FROM pizza
group by 1 , extract(dow from order_date)
order by extract(dow from order_date);

-- 7. Montly trend orders
SELECT 
    TO_CHAR(order_date, 'month') AS month,
	count(distinct order_id) as total_orders
FROM pizza
group by 1 , extract(month from order_date)
order by extract(month from order_date);

-- 8. Percentage of sales by pizza category 
select 
	pizza_category,
	sum(total_Price) as total_revenue,
	round(sum(total_price)* 100 / (select sum(total_price) from pizza),2) as total_revenue
from pizza
group by 1;