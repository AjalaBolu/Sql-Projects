create database coffee_analysis;

create table city (
	city_id	int primary key,
	city_name	varchar (20),
	population	bigint,
	estimated_rent	numeric,
	city_rank int
);

create table customers (
customer_id int primary key,
customer_name varchar (30),
city_id int,
constraint fk_city_id foreign key (city_id) references city (city_id)
);

create table products (
product_id	int primary key,
product_name	varchar (40),
price numeric
);

create table sales (
sale_id	int primary key,
sale_date date,
product_id int,
customer_id int,
total numeric,
rating int,
constraint fk_product_id foreign key (product_id) references products (product_id),
constraint fk_customer_id foreign key (customer_id) references customers (customer_id)
);

select * from city;
select * from customers;
select * from products;
select * from sales;

-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

select 
	city_name,
	round(population * 0.25/1000000, 2) as total_coffe_consumers
from city;

-- -- Q.2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

select 
	c.city_name,
	sum(total) as total_rev
from sales s
	JOIN customers cu
		on s.customer_id = cu.customer_id
	join city c
		on c.city_id = cu.city_id
where extract(year from sale_date) = 2023
	and 
		extract (quarter from sale_date) = 4
group by 1;

-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?

select 
	p.product_id,
	p.product_name,
	count(s.sale_id) as total_sold
from sales s
	 right join products p
		on s.product_id = p. product_id
group by 1,2
order by 1;

-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?
select 
	c.city_name,
	sum(s.total) as total_rev,
	count(distinct cu.customer_id) total_customers,
	round(sum(s.total)/count(distinct cu.customer_id), 2)as average_sales_per_cu
from sales s
	inner join customers cu 
		on s.customer_id = cu.customer_id
	inner join city c
		on cu.city_id =  c.city_id
group by 1;


-- -- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.

WITH population_per AS (
    SELECT 
        city_name,
        population,
        ROUND((population * 0.25)/1000000, 2) AS coffee_consumers_millions
    FROM city
)
SELECT * FROM population_per
ORDER BY population DESC;

-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
with city_rnk as 
(
	select 
		c.city_name,
		p.product_name,
		count(s.total) as total_sold,
		dense_rank() over(partition by c.city_name order by count(s.total) desc) as rnk
	from products p
	join sales s
		on p.product_id = s.product_id
	join customers cu 
		on s.customer_id = cu.customer_id
	join city c
		on cu.city_id = c.city_id
	group by 1,2
) 
select *
from city_rnk
where rnk <=3;