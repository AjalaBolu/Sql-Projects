CREATE TABLE taxi (
    vendor_id             INT,
    tpep_pickup_datetime  TIMESTAMP,
    tpep_dropoff_datetime TIMESTAMP,
    passenger_count       INT,
    trip_distance         NUMERIC(8,2),
    ratecode_id           INT,
    store_and_fwd_flag    VARCHAR(1),
    pu_location_id        INT,
    do_location_id        INT,
    payment_type          INT,
    fare_amount           NUMERIC(8,2),
    extra                 NUMERIC(8,2),
    mta_tax               NUMERIC(8,2),
    tip_amount            NUMERIC(8,2),
    tolls_amount          NUMERIC(8,2),
    improvement_surcharge NUMERIC(8,2),
    total_amount          NUMERIC(8,2),
    congestion_surcharge  NUMERIC(8,2)
);

select *
from taxi
limit 100 ;

-- index on pickup datetime 
CREATE INDEX idx_pickup_datetime ON taxi(tpep_pickup_datetime);

-- index on dropoff datetime 
CREATE INDEX idx_dropoff_datetime ON taxi(tpep_dropoff_datetime);

-- index on payment type 
CREATE INDEX idx_payment_type ON taxi(payment_type);

-- index on passenger count 
CREATE INDEX idx_passenger_count ON taxi(passenger_count);

-- ============================================
-- NYC TAXI TRIP ANALYSIS
-- Tool: PostgreSQL | pgAdmin
-- ============================================

-- Q1: How many total trips are in the dataset?

select 
	count(*)
from taxi;

-- Q2: What is the average trip distance, fare amount, and tip amount overall?

select 
	round(avg(trip_distance),2) as avg_trip_distance,
	round(avg(fare_amount),2) as avg_fare_amount,
	round(avg(tip_amount),2) as avg_tip_amount
from taxi;

-- Q3: What is the total revenue generated (sum of total_amount)?

select 
	sum(total_amount) as total_revenue
from taxi;

-- Q4: How many trips were taken per payment type?
-- (1 = Credit Card, 2 = Cash, 3 = No Charge, 4 = Dispute)

SELECT
    CASE 
        WHEN payment_type = 1 THEN 'Credit Card'
        WHEN payment_type = 2 THEN 'Cash'
        WHEN payment_type = 3 THEN 'No Charge'
        ELSE 'Dispute'
    END AS payment_type_desc,
    COUNT(*) AS total_trips
FROM taxi
GROUP BY 1;

-- Q5: What is the average fare amount by passenger count?

SELECT
    passenger_count,
    ROUND(AVG(fare_amount), 2) AS avg_fare
FROM taxi
GROUP BY 1
ORDER BY 1;

-- Q6: Which hour of the day has the most pickups?
-- (use EXTRACT on tpep_pickup_datetime)

select 
	extract (hour from tpep_pickup_datetime) as hour,
	count(*)
from taxi
group by 1 
order by count(*) desc;

-- Q7: Which day of the week has the highest number of trips?

select 
	case
		when extract (dow from tpep_pickup_datetime) = 1 then 'Monday'
		when extract (dow from tpep_pickup_datetime) = 2 then 'Tuesday'
		when extract (dow from tpep_pickup_datetime) = 3 then 'Wednesday'
		when extract (dow from tpep_pickup_datetime) = 4 then 'Thursday'
		when extract (dow from tpep_pickup_datetime) = 5 then 'Friday'
		when extract (dow from tpep_pickup_datetime) = 6 then 'Saturday'
		else 'Sunday'
	end as d_of_the_week,
	Count(*)
from taxi
group by 1
order by count(*) desc;

-- Q8: What is the average trip duration in minutes for each hour of the day?
-- (calculate duration from pickup and dropoff datetime)

select 
	extract (hour from tpep_pickup_datetime) as hour,
	round(avg(extract (epoch from (tpep_dropoff_datetime - tpep_pickup_datetime))/60),2) as avg_duration_minutes
from taxi
group by 1
order by 1 desc;

-- Q9: How does total revenue compare month over month?
-- (use DATE_TRUNC to group by month)

select 
	DATE_TRUNC('month', tpep_pickup_datetime) AS month,
	round(sum(total_amount),2) as total_revenue 
from taxi
group by 1
order by 1;

-- Q10: What is the average tip percentage per payment type?
-- (tip_amount / fare_amount * 100)

select 
	payment_type,
	round(avg (tip_amount / fare_amount * 100 ),2) as average_tip
from taxi
WHERE fare_amount > 0 
group by 1
;

-- Q11: Using LAG, show how the total number of trips changes day over day


WITH daily_trips AS (
SELECT 
    DATE_TRUNC('day', tpep_pickup_datetime) AS trip_date,
    COUNT(*) AS total_trips
FROM taxi
GROUP BY 1
)
SELECT
    trip_date,
    total_trips,
    LAG(total_trips) OVER (ORDER BY trip_date) AS previous_day_trips,
    total_trips - LAG(total_trips) OVER (ORDER BY trip_date) AS day_over_day_change
FROM daily_trips
ORDER BY trip_date;

-- Q12: What are the top 10 busiest pickup hours by average fare amount?

select 
	extract (hour from tpep_pickup_datetime) as hour ,
	round(avg(fare_amount),2) as avg_fare_amount,
	Count(*)
from taxi
group by 1
order by 3 desc
limit 10;

-- Q13: Find trips where the tip amount was higher than the fare amount —
-- how many such trips exist and what is the average total amount for them?

select 
	count(*) as total_trips,
	round(avg(total_amount),2) as avg_total_trips
from taxi
where tip_amount > fare_amount;

-- Q14: Using a window function, calculate the cumulative revenue by day
-- ordered by date

WITH daily_revenue AS (
    SELECT
        DATE_TRUNC('day', tpep_pickup_datetime) AS trip_date,
        SUM(total_amount) AS revenue
    FROM taxi
    GROUP BY 1
)
SELECT
    trip_date,
    revenue,
    SUM(revenue) OVER (ORDER BY trip_date) AS cumulative_revenue
FROM daily_revenue
ORDER BY trip_date;

-- Q15: What is the average trip distance and fare amount by hour bucket?
-- (Morning: 6-11, Afternoon: 12-17, Evening: 18-23, Night: 0-5)
WITH hourr AS (
    SELECT
        trip_distance,
        fare_amount,
        EXTRACT(HOUR FROM tpep_pickup_datetime) AS hour
    FROM taxi
)
SELECT 
    CASE
        WHEN hour BETWEEN 6 AND 11 THEN 'Morning'
        WHEN hour BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN hour BETWEEN 18 AND 23 THEN 'Evening'
        ELSE 'Night'
    END AS time_bucket,
    ROUND(AVG(trip_distance), 2) AS avg_distance,
    ROUND(AVG(fare_amount), 2) AS avg_fare
FROM hourr
GROUP BY 1;