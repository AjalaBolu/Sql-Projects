CREATE TABLE customers (
    customer_id              VARCHAR(50) PRIMARY KEY,
    customer_unique_id       VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city            VARCHAR(50),
    customer_state           VARCHAR(5)
);

CREATE TABLE orders (
    order_id                       VARCHAR(50) PRIMARY KEY,
    customer_id                    VARCHAR(50) REFERENCES customers(customer_id),
    order_status                   VARCHAR(20),
    order_purchase_timestamp        TIMESTAMP,
    order_approved_at               TIMESTAMP,
    order_delivered_carrier_date    TIMESTAMP,
    order_delivered_customer_date   TIMESTAMP,
    order_estimated_delivery_date   TIMESTAMP
);

CREATE TABLE order_items (
    order_id            VARCHAR(50) REFERENCES orders(order_id),
    order_item_id        INT,
    product_id           VARCHAR(50),
    seller_id            VARCHAR(50),
    shipping_limit_date   TIMESTAMP,
    price                 NUMERIC(10,2),
    freight_value         NUMERIC(10,2)
);

CREATE TABLE order_payments (
    order_id              VARCHAR(50) REFERENCES orders(order_id),
    payment_sequential     INT,
    payment_type           VARCHAR(20),
    payment_installments    INT,
    payment_value           NUMERIC(10,2)
);

CREATE TABLE order_reviews (
    review_id                  VARCHAR(50) PRIMARY KEY,
    order_id                   VARCHAR(50) REFERENCES orders(order_id),
    review_score                INT,
    review_comment_title         VARCHAR(100),
    review_comment_message       TEXT,
    review_creation_date          TIMESTAMP,
    review_answer_timestamp       TIMESTAMP
);

CREATE TABLE products (
    product_id                  VARCHAR(50) PRIMARY KEY,
    product_category_name        VARCHAR(50),
    product_name_length           INT,
    product_description_length     INT,
    product_photos_qty             INT,
    product_weight_g                INT,
    product_length_cm                INT,
    product_height_cm                INT,
    product_width_cm                 INT
);

CREATE TABLE sellers (
    seller_id              VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix   VARCHAR(10),
    seller_city              VARCHAR(50),
    seller_state              VARCHAR(5)
);

CREATE TABLE category_translation (
    product_category_name          VARCHAR(50) PRIMARY KEY,
    product_category_name_english   VARCHAR(50)
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat               NUMERIC(10,6),
    geolocation_lng               NUMERIC(10,6),
    geolocation_city               VARCHAR(50),
    geolocation_state               VARCHAR(5)
);


-- Data importation and testing

select *
from customers;

select *
from orders;

select *
from order_items;

select *
from order_payments;

ALTER TABLE order_reviews DROP CONSTRAINT order_reviews_pkey;

select * 
from order_reviews;

select * 
from products;

select * 
from sellers;

select * 
from category_translation;

select * 
from geolocation;


-- check orders links to customers
SELECT COUNT(*) FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

-- check order_items links to orders
SELECT COUNT(*) FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id;

-- check order_payments links to orders
SELECT COUNT(*) FROM order_payments op
JOIN orders o ON op.order_id = o.order_id;

-- check order_reviews links to orders
SELECT COUNT(*) FROM order_reviews r
JOIN orders o ON r.order_id = o.order_id;

-- check order_items links to products
SELECT COUNT(*) FROM order_items oi
JOIN products p ON oi.product_id = p.product_id;

-- check order_items links to sellers
SELECT COUNT(*) FROM order_items oi
JOIN sellers s ON oi.seller_id = s.seller_id;


-- OLIST BRAZILIAN E-COMMERCE ANALYSIS TASKS

-- Q1: How many orders were placed in total, and how many
-- customers placed them?

Select 
	count(o.order_id),
	count(distinct c.customer_id)
from orders o 
	join customers c
		on o.customer_id = c.customer_id;


-- Q2: What is the distribution of order statuses?
-- (delivered, shipped, cancelled, etc.)

select 
	order_status,
	count(*)
from orders
group by 1
order by 2 desc;

-- Q3: What is the total revenue generated across all orders?
-- (revenue = sum of price + freight_value from order_items)

select 
	sum(price + freight_value) as total_revenue
from order_items;

-- Q4: What are the top 10 product categories by number of orders?
-- (use category_translation to show English category names)

select 
	c.product_category_name_english,
	count(oi.order_id) as total_units_sold
from products as p
	join category_translation as c
		on p.product_category_name = c.product_category_name
	join order_items oi
		on p.product_id = oi.product_id
group by 1
order by 2 desc;


-- Q5: What is the average order value per customer state?

select 
	c.customer_state,
	round(avg(oi.price + oi.freight_value),2) as avg_price
from order_items as oi
join orders as o
	on oi.order_id = o.order_id
join customers as c
	on o.customer_id = c.customer_id
group by 1
order by 2 desc;


-- Q6: Which sellers have generated the most revenue?
-- Show the top 10.

select 
	s.seller_id,
	sum(oi.price) as total_revenue
from sellers as s
join order_items as oi
	on s.seller_id = oi.seller_id
group by 1
order by 2 desc
limit 10;
	
-- Q7: What is the average review score per product category?
-- Which category has the best and worst ratings?

select 
	c.product_category_name_english,
	round(avg(review_score),2) as avg_review_sore
from order_reviews as o
join order_items as oi 
	on o.order_id = oi.order_id
join products as p
	on oi.product_id = p.product_id
join category_translation as c
	on p.product_category_name = c.product_category_name
group by 1
order by 2 desc;


select * from products;

-- Q8: How many orders were delivered late?
-- (delivered after the estimated delivery date)
-- What percentage of all delivered orders is that?


select 
 	count(*) as late_orders,
	round(count(*) * 100.00 / (SELECT COUNT(*) FROM orders WHERE order_status = 'delivered'), 2) AS late_percentage
from orders
where order_delivered_customer_date > order_estimated_delivery_date;

-- Q9: What is the most common payment type used by customers?
-- Show the count and percentage for each.

select 
	payment_type,
	count(payment_type) as total_times_used,
	round(count(payment_type) * 100.0 / (select count(*) from order_payments),2) as perentage 
from order_payments
group by 1
order by 2 desc ;

-- Q10: What is the average number of installments used
-- per payment type?

select 
	payment_type,
	round(avg(payment_installments),2) as avg_installments
from order_payments
group by 1;

-- Q11: Which customer states have the highest average
-- review scores?

select 
	c.customer_state as state,
	round(avg(review_score),2) as avg_reviwe_score
from order_reviews as orr
join orders as o
	on orr.order_id = o.order_id
join customers as c
	on o.customer_id = c.customer_id
group by 1
order by 2 desc;
	
-- Q12: What is the monthly order trend?
-- Show total orders and revenue per month.

select 
	date_trunc ('month', o.order_purchase_timestamp ) as month,
	COUNT(o.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value)::NUMERIC, 2) AS total_revenue
from order_items as oi 
join orders as o
	on oi.order_id = o.order_id
group by 1
order by 1;
	
-- Q13: Using a window function, rank sellers by revenue
-- within each state.

select 
	s.seller_state,
	s.seller_id,
	sum(oi.price) as total_revenue,
	row_number () over (partition by s.seller_state  order by sum(oi.price) desc)
from sellers as s
join order_items as oi
	on s.seller_id = oi.seller_id
group by 1,2;

-- Q14: What is the average delivery time in days per state?
-- (from order purchase to actual delivery)

SELECT
    c.customer_state,
    ROUND(AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) / 86400)::NUMERIC, 2) AS avg_delivery_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

-- Q15: Build a seller performance profile — for each seller
-- show total orders, total revenue, average review score,
-- and on-time delivery rate. Filter to sellers with
-- at least 10 orders.

with details as
(
	select 
		s.seller_id as seller_id,
		count(*) as total_sales,
		sum(oi.price) as total_revenue,
		round(avg(ore.review_score),2) as avg_review_score,
		ROUND(COUNT(CASE WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 1 END) * 100.0 / COUNT(*), 2) AS on_time_delivery_rate
	from sellers as s
	join order_items oi
		on s.seller_id = oi.seller_id
	join order_reviews as ore
		on oi.order_id = ore.order_id
	join orders as o
		on oi.order_id = o.order_id
	group by 1
)
select 
	seller_id,
	total_sales,
	total_revenue,
	avg_review_score,
	on_time_delivery_rate
from details 
where total_sales >= 10
order by 2;