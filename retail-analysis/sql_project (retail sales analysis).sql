-- sql project sales analysis

--Creating the database
create database p1_retail_db;
use p1_retail_db;

-- creating the table
create table retail_sales 
(
	transactions_id	int primary key,
	sale_date	date,
	sale_time time,
	customer_id	 int,
	gender varchar (10),
	age int,
	category varchar(20),	
	quantity	int,
	price_per_unit float ,	
	cogs float,
	total_sale float -- best practice use decimal rather than float
); 


select * 
from retail_sales;

select count (*)
from retail_sales;

SELECT
	 COUNT(DISTINCT customer_id) 
FROM retail_sales;

SELECT
	DISTINCT category 
FROM retail_sales;

-- Data cleaning 

select *
from retail_sales
where 
	transactions_id is null or
	sale_date is null or
	sale_time is null or
	customer_id is null or
	gender is null or
	age is null or
	category is null or
	quantity is null or
	price_per_unit is null or
	cogs is null or
	total_sale is null

-- deleting null values
delete from retail_sales
where 
	transactions_id is null or
	sale_date is null or
	sale_time is null or
	customer_id is null or
	gender is null or
	age is null or
	category is null or
	quantity is null or
	price_per_unit is null or
	cogs is null or
	total_sale is null
	

-- EDA

select * 
from retail_sales;

-- how many sales do we have

select count (*) total_sales 
from retail_sales;

-- how many unique coustomers do we have

select count (distinct customer_id) total_coustomers 
from retail_sales;


-- number of male coustomer
select 
	count (gender)
from retail_sales
where gender = 'Male';

-- number of female coustomer
select 
	count (gender)
from retail_sales
where gender = 'Female';

-- maximum age of each gender

select max(age),gender
from retail_sales
group by gender;

-- minimum age of each gender

select min(age),gender
from retail_sales
group by gender;


-- Total quantity bought by gender in each category
SELECT
    category,
    gender,
    sum(quantity) AS total_units_bought 
FROM retail_sales
GROUP BY
    category,
    gender
ORDER BY
    category,
    total_units_bought DESC;

-- sum of total sales made by each gender in each category
select 
	gender,
	category,
	sum(total_sale) as total_sales
from retail_sales
group by 
	gender,
	category
order by
	gender,
	total_sales;

-- total coustomers by gender 
select
	count(customer_id) as total_coustomers,
	gender
from retail_sales
group by 
	gender
order by 
	total_coustomers;

-- Data analysis
-- find all sales made on '2022-11-05'

select *
from retail_sales
where sale_date = '2022-11-05';

-- find all sales where the category is clothing, quantity sold is > 4 in the month of nov 2022
select *
from retail_sales
where 
	category = 'Clothing'
	and
	to_char(sale_date, 'YYYY-MM')= '2022-11'
	and
	quantity >= 4;

-- find the total sales for each category

select 
	category,
	sum(total_sale) net_sale,
	count(*) total_orders
from retail_sales
group by category;

-- find the average age of coustomers who purchased items from the beauty category
select 
	category,
	gender,
	round(avg(age),2) avg_age
from retail_sales
where category = 'Beauty'
group by category , gender;

-- writr a sql querey to find all trasactions where the total_sales is > 1000.

select *
from retail_sales
where total_sale > 1000;

-- find the total number of transactions made by each gender in each category
select 
	category,
	gender,
	count(distinct transactions_id) total_transaction
from retail_sales
group by gender, category
order by category;

--find the avg sales per month, find the best selling month in each year
select * 
from
(
	SELECT
	    EXTRACT(YEAR FROM sale_date)  as year, 
	    EXTRACT(MONTH FROM sale_date) as month,  
	    AVG(total_sale) avg_sales,
		rank () over (partition by EXTRACT(YEAR FROM sale_date) order by AVG(total_sale) desc)
	FROM retail_sales
	GROUP BY
	    year,
	    month
) as t1
where rank = 1;

-- find the top 5 coustomers based on the total sales
select 
	customer_id,
	sum(total_sale) total_sales
from retail_sales
group by customer_id
order by total_sales desc
limit 5;

-- find the unique coustomers who purchased items from each category
select 
	count(distinct customer_id),
	category 
from retail_sales
group by category;

-- write a sql querey to create each shift and the number of orders
with hourly_sales as
(
	select *,
	EXTRACT(YEAR FROM sale_date)  as year, 
	EXTRACT(MONTH FROM sale_date) as month,
		case
			when extract (hour from sale_time) < 12 then 'Morning'
			when extract (hour from sale_time) between 12 and 17 then 'Afternoon'
			else 'Evening'
		end as shifts
	from retail_sales
)
select 
	year,
	month,
	shifts,
	count(transactions_id)
from hourly_sales
group by 
	year,
	month,
	shifts
order by 
	year,
	month;
	
-- find how much each coustomer has spent 
select
 customer_id,
 sum(total_sale) lifetime_spend
from retail_sales
group by
	customer_id
order by 
	lifetime_spend desc;

-- Monthly Sales Trends *
select 
	extract(year from sale_date) as Year,
	extract(month from sale_date) as Month,
	category,
	sum(total_sale)
from 
	retail_sales
group by 
	Year,
	Month,
	category
order by 
	year,
	month;

-- age 
SELECT 
  CASE 
    WHEN age BETWEEN 18 AND 25 THEN '18-25'
    WHEN age BETWEEN 26 AND 35 THEN '26-35'
    WHEN age BETWEEN 36 AND 45 THEN '36-45'
    ELSE '46+'
  END AS age_group,
  category,
  SUM(total_sale) AS sales
FROM retail_sales
GROUP BY age_group, category
ORDER BY
	AGE_GROUP;

-- Profit 

SELECT category,
       SUM(total_sale - cogs) AS profit
FROM retail_sales
GROUP BY category;


-- Profit per year
SELECT 
	extract (year from sale_date) as Year,
	category,
	SUM(total_sale - cogs) AS profit
FROM retail_sales
GROUP BY 
	category,
	Year
order by 
	Year;

-- Profit per month
SELECT 
	extract (year from sale_date) as Year,
	extract (month from sale_date) as Month,
	category,
	SUM(total_sale - cogs) AS profit
FROM retail_sales
GROUP BY 
	category,
	Year,
	month
order by 
	Year,
	month;
	
--END