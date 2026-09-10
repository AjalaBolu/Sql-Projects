-- ============================================================
-- Northwind Database — SQL Practice Tasks
-- Core tables: customers, orders, order_details, products
-- (also available: employees, categories, shippers, suppliers)
-- Focus: window functions, CTEs, joins, conditional aggregation
-- Order total for a single order = SUM(unit_price * quantity * (1 - discount))
-- ============================================================


-- ============================================================
-- SECTION 1: GETTING COMFORTABLE (no window functions yet)
-- ============================================================

-- for this project we will only be using this four tables 
select * from orders;
select * from order_details;
select * from customers;
select * from products;

-- Task 1: Total number of orders and total revenue per customer.

select  
	c.contact_name as full_name,
	count(distinct od.order_id) total_times_ordered,
	round(sum(od.unit_price * od.quantity * (1 - od.discount))::numeric ,2) as total_spent
from order_details as od
join orders as o
	on od.order_id = o.order_id
join customers as c
	on o.customer_id = c.customer_id
group by 1;

-- Task 2: Total revenue per product category.

select  
	cat.category_name,
	round(sum(od.unit_price * od.quantity * (1 - od.discount))::numeric ,2) as total_revenue
from order_details as od
join products as p
	on od.product_id = p.product_id
join categories as cat
	on p.category_id = cat.category_id
group by 1
order by 2 desc;

-- Task 3: Average discount given per product category.
-- this is "average discount among discounted orders only, not overall discount rate
select  
	cat.category_name,
	round(avg(od.discount)::numeric,2)
from order_details as od
join products as p
	on od.product_id = p.product_id
join categories as cat
	on p.category_id = cat.category_id
where od.discount > 0
group by 1
order by 2;

-- ============================================================
-- SECTION 2: WINDOW FUNCTIONS — RANKING
-- ============================================================

-- Task 4: Rank customers by total revenue overall (RANK vs DENSE_RANK,
-- show where they diverge).

with tr as (
select  
	c.contact_name as full_name,
	round(sum(od.unit_price * od.quantity *(1 - od.discount))::numeric,2) as total_revenue
from order_details as od
join orders as o
	on od.order_id = o.order_id
join customers as c
	on o.customer_id = c.customer_id
group by 1
)
Select 
	full_name,
	total_revenue,
	rank() over(order by total_revenue desc),
	dense_rank() over(order by total_revenue desc)
from tr;

-- Task 5: Rank products by total revenue within each category.

with total_revenue as (
select  
	cat.category_name as category,
	p.product_name,
	round(sum(od.unit_price * od.quantity * (1 - od.discount))::numeric ,2) as total_revenue
from order_details as od
join products as p
	on od.product_id = p.product_id
join categories as cat
	on p.category_id = cat.category_id
group by 1,2
)
select 
	category,
	product_name,
	total_revenue,
	rank() over(partition by category order by total_revenue desc),
	dense_rank() over(partition by category order by total_revenue desc)
from total_revenue;
	
-- Task 6: Rank employees by number of orders handled.
with toh as (
select 
	concat(e.first_name, ' ' , e.last_name) as full_name,
	count(distinct o.order_id) as total_orders_handled
from orders as o
join employees as e
	on o.employee_id = e.employee_id
group by 1
)
select 
	*,
	rank() over(order by total_orders_handled desc)
from toh;

-- Task 7: Within each country, rank customers by total revenue.

with tr as (
select  
	c.contact_name as full_name,
	c.country as country,
	round(sum(od.unit_price * od.quantity *(1 - od.discount))::numeric,2) as total_revenue
from order_details as od
join orders as o
	on od.order_id = o.order_id
join customers as c
	on o.customer_id = c.customer_id
group by 1,2
)
Select 
	country,
	full_name,
	total_revenue,
	rank() over(partition by country order by total_revenue desc)
from tr;

-- ============================================================
-- SECTION 3: WINDOW FUNCTIONS — LAG/LEAD
-- ============================================================

-- Task 8: For each customer, show the days between their current
-- order and their previous order (LAG on order_date).

select
    c.contact_name as full_name,
    o.order_date as current_order_date,
    lag(o.order_date) over (partition by o.customer_id order by o.order_date) as previous_order_date,
	o.order_date - lag(o.order_date) over (partition by o.customer_id order by o.order_date) as day_gap
from orders as o
join customers as c
    on o.customer_id = c.customer_id;

-- Task 9: Month-over-month change in total order count, company-wide
-- (LAG).

select 
	date_trunc('month', order_date) as month,
	count(order_id) as current_order_count,
	lag(count(order_id)) over (order by date_trunc('month', order_date)) as previous_month_order_count,
	count(order_id) - lag(count(order_id)) over (order by date_trunc('month', order_date)) as diff
from orders
group by 1
order by 1;

-- Task 10: Month-over-month % change in total revenue, company-wide.
with tr as (
select 
	date_trunc('month', order_date) as month,
	round(sum(od.unit_price * od.quantity *(1 - od.discount))::numeric,2) as total_revenue
from orders as o
join order_details as od
	on o.order_id = od.order_id
group by 1
order by 1
),
pmr as 
(
select 
	month,
	total_revenue,
	lag(total_revenue) over (order by month) as previous_month_total_revenue,
	total_revenue - lag(total_revenue) over (order by month) as diff
from tr
)
select 
	*,
	round(diff / previous_month_total_revenue * 100 ,2) as change_percentage
from pmr;

-- Task 11: For each customer's orders in sequence, flag whether the
-- order value increased or decreased vs their previous order.

with ams as 
(
	select 
		o.customer_id,
		c.contact_name as full_name,
		o.order_date as order_date,
		od.order_id,
		round(sum(od.unit_price * od.quantity * (1 - od.discount)):: numeric, 2) as amount_spent
	from customers as c 
	join orders as o
		on c.customer_id = o.customer_id
	join order_details as od
		on o.order_id = od.order_id
	group by 1,2,3,4
	order by 2,3
)
select 
	*,
	lag(amount_spent) over(partition by customer_id order by order_date) as previous_order_amount,
	amount_spent - lag(amount_spent) over(partition by customer_id order by order_date) as diff,
	case 
		when amount_spent - lag(amount_spent) over(partition by customer_id order by order_date) > 0 then 'Increased'
		when amount_spent - lag(amount_spent) over(partition by customer_id order by order_date) < 0 then 'Decreased'
		when amount_spent - lag(amount_spent) over(partition by customer_id order by order_date) = 0 then 'Same'
		else 'Null'
	end
from ams;

-- ============================================================
-- SECTION 4: WINDOW FUNCTIONS — RUNNING TOTALS & FRAMES
-- ============================================================

-- Task 12: Running total of revenue per customer, ordered by
-- order_date (their cumulative lifetime spend over time).

with tr as 
(
select 
	c.contact_name,
	round(sum(od.unit_price * od.quantity * (1 - od.discount)):: numeric, 2) as amount_spent,
	o.order_date
from orders as o 
join order_details as od
	on o.order_id = od.order_id 
join customers as c
	on o.customer_id = c.customer_id
group by 1,3
)
select 
	contact_name,
	order_date,
	sum(amount_spent) over (partition by contact_name order by order_date)
from tr;

-- Task 13: Running total of company-wide revenue over time (by month).

with tr as (
select 
	date_trunc('month', order_date) as monthh,
	round(sum(od.unit_price * od.quantity *(1 - od.discount))::numeric,2) as total_revenue
from orders as o
join order_details as od
	on o.order_id = od.order_id
group by 1
order by 1
)
select 
	monthh,
	sum(total_revenue) over (order by monthh) as running_total
from tr;

-- Task 14: Rolling 3-order average order value per customer
-- (ROWS BETWEEN 2 PRECEDING AND CURRENT ROW).

with tr as (
	select 
		c.contact_name,
		o.order_date,
		round(sum(od.quantity * od.unit_price *(1 - od.discount))::numeric, 2) as total_spent
	from order_details as od 
	join orders as o
		on od.order_id = o.order_id
	join customers as c
		on c.customer_id = o.customer_id
	group by 1,2
)
select 
	contact_name,
	order_date,
	round(avg(total_spent) over (partition by contact_name order by order_date rows between 2 preceding
							and current row)::numeric,2)
from tr;

-- Task 15: Running count of orders per customer, order-by-order.
with tor as (
	select 
		c.contact_name,
		o.order_date,
		o.order_id
	from orders as o
	join customers as c
		on c.customer_id = o.customer_id
)
select 
	contact_name,
	order_date,
	count(order_id) over(partition by contact_name order by order_date) as running_total
from tor;

-- ============================================================
-- SECTION 5: WINDOW FUNCTIONS — FIRST_VALUE/LAST_VALUE/NTILE
-- ============================================================

-- Task 16: Each customer's first order date and most recent order date
-- (customer lifespan).

select
    c.contact_name,
    o.order_date,
    first_value(o.order_date) over (partition by c.contact_name order by o.order_date) as first_order_date,
	last_value(o.order_date) over (partition by c.contact_name order by o.order_date rows between unbounded preceding and unbounded following) as last_order_date
from orders as o
join customers as c
    on o.customer_id = c.customer_id;

-- Task 17: Each customer's single highest-value order (FIRST_VALUE
-- over a value-ordered window, or plain rank + filter).

with ts as (
select 
	c.contact_name,
	o.order_date,
	round(sum(od.quantity * od.unit_price *(1 - od.discount))::numeric, 2) as total_spent
from order_details as od 
join orders as o 
	on od.order_id = o.order_id
join customers as c
	on o.customer_id = c.customer_id
group by 1,2
), rnk as ( 
select 
	contact_name,
	order_date,
	total_spent,
	rank() over (partition by contact_name order by total_spent desc) as rankk
from ts
)
select 
	contact_name,
	total_spent,
	order_date
from rnk
where rankk = 1;

-- Task 18: Bucket customers into quartiles by total lifetime spend
-- using NTILE.
with ts as (
select 
	c.contact_name,
	round(sum(od.quantity * od.unit_price *(1 - od.discount))::numeric, 2) as total_spent
from order_details as od 
join orders as o 
	on od.order_id = o.order_id
join customers as c
	on o.customer_id = c.customer_id
group by 1
)
select 
	contact_name,
	total_spent,
	ntile(4) over (order by total_spent desc) as qtil
from ts;


-- Task 19: Bucket products into quartiles by total revenue using
-- NTILE, per category.
with tr as (
select 
	p.product_name,
	c.category_name,
	round(sum(od.unit_price * od.quantity * (1 - od.discount))::numeric,2) as total_rev
from order_details as od
join products as p
	on od.product_id = p.product_id
join categories as c
	on p.category_id = c.category_id
group by 1,2
)
select
	product_name,
	category_name,
	total_rev,
	ntile(4) over (partition by category_name order by total_rev desc)
from tr;
-- ============================================================
-- SECTION 6: CTEs — MULTI-STEP LOGIC
-- ============================================================

-- Task 20: Customers whose total spend increased every consecutive
-- month they ordered (needs a monthly-spend CTE first, then a
-- comparison across rows).

with tspm as 
(
	select 
		c.contact_name as full_name,
		date_trunc ('month',o.order_date) as month,
		round(sum(od.unit_price * od.quantity * (1 - od.discount)):: numeric, 2) as amount_spent
	from customers as c 
	join orders as o
		on c.customer_id = o.customer_id
	join order_details as od
		on o.order_id = od.order_id
	group by 1,2
),last_month as (
select
	full_name,
	month,
	amount_spent,
	lag(amount_spent) over (partition by full_name order by month) as pas
from tspm
), flagged as(
select 
	full_name,
	month,
	amount_spent,
	pas,
	case
		when pas is null then null
		when amount_spent > pas then 1
		else 0
	end as increase
from last_month
) 
select 
    full_name,
    min(increase) as worst_flag
from flagged
group by full_name
having min(increase) = 1;

-- Task 21: "One-time customers" — customers with exactly one order
-- ever.

select 
	c.contact_name,
	count(o.order_id) as total_orders
from customers as c
join orders as o
	on c.customer_id = o.customer_id
group by 1
having count(o.order_id) < 2;

-- Task 22: Products that have NEVER been ordered (check order_details
-- for missing product_ids — careful with join direction here).

select 
	p.product_name
from products as p
left join order_details as od
	on p.product_id = od.product_id
where od.order_id is null;

-- Task 23: Top 3 products by revenue within EACH category (needs a
-- ranked CTE, then filter to rank <= 3 — can't filter directly on a
-- window function in WHERE).
with tr as (
	select 
		p.product_name,
		c.category_name,
		round(sum(od.unit_price * od.quantity * (1 - od.discount))::numeric,2) as total_revenue
	from products as p
	join order_details as od
		on p.product_id = od.product_id
	join categories as c
		on p.category_id = c.category_id
	group by 1,2
), rnk as(
	select
		category_name,
		product_name,
		total_revenue,
		rank() over(partition by category_name order by total_revenue desc) as rankk
	from tr
)
select
	*
from rnk
where rankk <= 3;
-- ============================================================
-- SECTION 7: CONDITIONAL AGGREGATION
-- ============================================================

-- Task 24: % of orders that included any discount, per category.

select 
    c.category_name,
    round(
        count(case when od.discount > 0 then 1 end)::numeric 
        * 100 / count(od.order_id), 
        2
    ) as pct_discounted
from products as p
join order_details as od
    on p.product_id = od.product_id
join categories as c
    on p.category_id = c.category_id
group by 1;

-- Task 25: Average order value for discounted vs non-discounted
-- orders, per category.
with tr as(
 select
        od.order_id,
        c.category_name,
        max(od.discount) as max_discount,
        round(sum(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) as order_total
    from order_details as od
    join products as p on od.product_id = p.product_id
    join categories as c on p.category_id = c.category_id
    group by od.order_id, c.category_name
)
select 
	category_name,
	round(avg(case when max_discount > 0 then order_total end),2) as avg_discounted_value,
	round(avg(case when max_discount = 0 then order_total end),2) as avg_non_discounted_value
from tr
group by 1;

-- Task 26: Late shipment rate (%) — orders where shipped_date is
-- meaningfully after order_date — per employee.

select
	concat(e.first_name,' ',e.last_name) as full_name,
	round(count(case when shipped_date - order_date > 7 then 1 end)
	::numeric * 100 / count(order_id),2) as late
from orders as o 
join employees as e 
	on o.employee_id = e.employee_id
group by 1;

-- ============================================================
-- SECTION 8: JOINS ACROSS MULTIPLE TABLES
-- ============================================================

-- Task 27: For each employee, total revenue generated and total
-- number of unique customers they've served.

select 
	concat(e.first_name,' ', e.last_name) as full_name,
	round(sum(od.unit_price * od.quantity *(1 - od.discount))::numeric,2) as total_revenue_genereted,
	count(distinct c.customer_id) as total_people_served
from employees as e 
join orders as o
	on e.employee_id = o.employee_id
join customers as c
	on o.customer_id = c.customer_id
join order_details as od
	on o.order_id = od.order_id
group by 1;

-- Task 28: For each country, the single best-selling product
-- (highest quantity sold).

with total_sold as (
select 
	o.ship_country,
	p.product_name,
	sum(quantity) as total_units_sold
from orders as o
join order_details as od
	on o.order_id = od.order_id
join products as p 
	on od.product_id = p.product_id
group by 1,2
)
select *
from (
	select
		ship_country,
		product_name,
		total_units_sold,
		dense_rank() over (partition by ship_country order by total_units_sold desc) as rnk
	from total_sold
) as ranked
where rnk = 1;

-- Task 29: Customers who have ordered from every product category
-- available (a "buys everything" segment).

select 
	c.customer_id,
	c.contact_name,
	count(distinct ct.category_name)
FROM customers as c
join orders as o
	on c.customer_id = o.customer_id
join order_details as od 
	on o.order_id = od.order_id
join products as p
	on od.product_id = p.product_id
join categories as ct 
	on p.category_id = ct.category_id
group by 1,2
having count(distinct ct.category_name) = (select count(*) from categories);

-- ============================================================
-- SECTION 9: PERCENTAGE/RATIO TRAPS
-- ============================================================

-- Task 30: Revenue per unit of stock remaining, per product — i.e.
-- which products are selling well relative to how much inventory
-- is left (watch for products with units_in_stock = 0, division
-- by zero).

select 
	p.product_name,
	p.units_in_stock,
	round(sum(od.quantity * od.unit_price * (1 - od.discount))::numeric,2) as total_revenue,
	round(round(sum(od.quantity * od.unit_price * (1 - od.discount))::numeric,2) / nullif(p.units_in_stock,0),2) as rev_per_unit
from products as p 
join order_details as od
	on p.product_id = od.product_id
group by 1,2
order by 2 desc;