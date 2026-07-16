# NYC Taxi Trip Analysis

## Project Overview
This project analyzes 6.4 million NYC yellow taxi trip records using PostgreSQL, focusing on time-series patterns, revenue trends, and trip behavior. With a dataset of this size, the project also incorporates indexing strategies to improve query performance — a step not required on smaller, single-table projects in this portfolio.

The dataset was clean on import — no preprocessing was required before loading into pgAdmin.

---

## Dataset
- **Rows:** 6,405,008 trips
- **Schema:** Single table (`taxi`)

### Table Schema
```sql
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
```

### Indexing
Given the size of the dataset (6.4M+ rows), indexes were created on the columns most frequently used for filtering and grouping, to keep query execution times manageable:

```sql
CREATE INDEX idx_pickup_datetime ON taxi(tpep_pickup_datetime);
CREATE INDEX idx_dropoff_datetime ON taxi(tpep_dropoff_datetime);
CREATE INDEX idx_payment_type ON taxi(payment_type);
CREATE INDEX idx_passenger_count ON taxi(passenger_count);
```

---

## Business Questions

| # | Question | SQL Concept |
|---|---|---|
| Q1 | How many total trips are in the dataset? | COUNT |
| Q2 | What is the average trip distance, fare amount, and tip amount overall? | AVG |
| Q3 | What is the total revenue generated? | SUM |
| Q4 | How many trips were taken per payment type? | CASE WHEN, GROUP BY |
| Q5 | What is the average fare amount by passenger count? | GROUP BY, AVG |
| Q6 | Which hour of the day has the most pickups? | EXTRACT(HOUR), GROUP BY |
| Q7 | Which day of the week has the highest number of trips? | EXTRACT(DOW), CASE WHEN |
| Q8 | What is the average trip duration in minutes for each hour of the day? | EPOCH, timestamp subtraction |
| Q9 | How does total revenue compare month over month? | DATE_TRUNC |
| Q10 | What is the average tip percentage per payment type? | Conditional division, AVG |
| Q11 | Using LAG, show how the total number of trips changes day over day | CTE, LAG, DATE_TRUNC |
| Q12 | What are the top 10 busiest pickup hours by trip volume, with average fare? | GROUP BY, ORDER BY, LIMIT |
| Q13 | Find trips where the tip amount was higher than the fare amount | WHERE filter, AVG |
| Q14 | Calculate cumulative revenue by day using a window function | CTE, SUM() OVER (running total) |
| Q15 | What is the average trip distance and fare amount by time-of-day bucket? | CTE, CASE WHEN bucketing |

---

## Key Findings

**Busiest Pickup Hour**
6 PM (hour 18) had the highest number of pickups — consistent with evening rush hour as commuters head home from work.

**Trip Duration Analysis**
Trip duration was calculated using `EPOCH` to convert the time difference between pickup and dropoff into minutes, broken down by hour of day — surfacing how traffic congestion at different times of day affects how long trips take, independent of distance.

**Tip Behavior**
Tip percentage was calculated relative to fare amount (not as a flat dollar figure) to fairly compare tipping behavior across trips of different fare sizes, broken down by payment type.

**High-Tip Outlier Trips**
A subset of trips were identified where the tip amount exceeded the fare amount itself — an interesting outlier segment worth flagging for further investigation (potential data entry anomalies or unusually generous tips).

**Revenue Trends**
Monthly revenue trends were tracked using `DATE_TRUNC`, and a cumulative running total of daily revenue was calculated using a window function (`SUM() OVER`), giving a clear view of revenue accumulation over time.

**Time-of-Day Patterns**
Trips were bucketed into Morning, Afternoon, Evening, and Night windows to compare average trip distance and fare amount across the day — useful for understanding how demand and trip characteristics shift throughout daily cycles.

---

## SQL Concepts Demonstrated
- Working with large datasets (6.4M+ rows) and using indexing to optimize query performance
- Datetime manipulation: `EXTRACT`, `DATE_TRUNC`, `EPOCH`
- Window functions: `LAG()`, `SUM() OVER()` for running totals
- CTEs for multi-step time-series analysis
- Conditional aggregation with `CASE WHEN`
- Time-of-day and day-of-week bucketing

---

## How to Run
1. Download the NYC Taxi trip dataset
2. Create the table using the schema provided
3. Import the CSV into pgAdmin
4. Run the indexing statements to improve query performance
5. Run the queries from `nyc_taxi_analysis.sql`

---

## Author
**Ajala Boluwatife Oluwanifemi**
LinkedIn: [Ajala Boluwatife](https://www.linkedin.com/in/ajala-boluwatife-2b2854316)
Portfolio: [SQL Projects](https://github.com/AjalaBolu/SQL-PROJECTS)
