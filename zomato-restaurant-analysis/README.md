# 🍽️ Zomato SQL Analysis Project

A comprehensive SQL data analysis project built on a Zomato-inspired food delivery dataset. This project covers everything from database design and data cleaning to advanced SQL analytics across 8 progressive skill levels.

---

## 📁 Project Structure

```
zomato/
├── datasets/
│   ├── orders_cleaned.csv
│   ├── order_details.csv
│   ├── restaurants_cleaned.csv
│   ├── meals.csv
│   ├── members.csv
│   ├── serve_types_cleaned.csv
│   ├── monthly_members_cleaned.csv
│   └── ...
├── queries/
│   ├── level_1_beginner.sql
│   ├── level_2_aggregations.sql
│   ├── level_3_joins.sql
│   ├── level_4_datetime.sql
│   ├── level_5_case.sql
│   ├── level_6_subqueries.sql
│   ├── level_7_window_functions.sql
│   └── level_8_business_problems.sql
└── README.md
```

---

## 🗄️ Database Schema

The database consists of 9 tables designed to model a food delivery platform:

```sql
cities            -- City reference data
restaurant_type   -- Restaurant cuisine/type categories
serve_type        -- Meal serve types (Starter, Main, Dessert)
meal_types        -- Meal category types
restaurant        -- Restaurant details with city and type references
meals             -- Menu items with pricing and categorization
members           -- Customer profiles with city and budget info
orders            -- Order transactions with timestamps
order_details     -- Individual meal items per order
monthly_members   -- Aggregated monthly member statistics
```

### Entity Relationship Overview

```
cities ──────────── restaurant ──────────── orders ──────────── order_details
                         │                     │                      │
               restaurant_type              members                 meals
                                                │                     │
                                             cities              serve_type
                                                                 meal_types
```

---

## 🔧 Data Cleaning & Import

Before importing, several datasets required cleaning:

### `orders.csv`
- **Issue 1:** Separate `date` and `hour` columns instead of a single `order_timestamp`
- **Issue 2:** `hour` column stored minutes as `25:00.0` instead of proper time format
- **Fix:** Merged `date` + `hour` into `order_timestamp` and converted minutes to `HH:MM:SS` format using Python/Pandas

### `restaurants.csv`
- **Issue 1:** Column named `income_persentage` (typo)
- **Issue 2:** Values stored as decimals (`0.075`) instead of percentages (`7.50`)
- **Fix:** Renamed column and multiplied values by 100 to match `NUMERIC(5,2)` schema

### `serve_types.csv`
- **Issue:** `Desert` misspelled (should be `Dessert`)
- **Fix:** Corrected spelling using Pandas `.replace()`

### `monthly_members.csv`
- **Issue:** Floating point precision errors in `commission` and `monthly_budget` columns
- **Fix:** Rounded all affected columns to 2 decimal places

### Import Order
Due to foreign key constraints, tables must be imported in this order:
```
1. cities
2. restaurant_type
3. serve_type
4. meal_types
5. restaurant
6. meals
7. members
8. orders
9. order_details
10. monthly_members
```

---

## 📊 SQL Analysis — 8 Levels

---

### 🟢 Level 1 — Beginner: Data Retrieval & Filtering

**Skills:** `SELECT` `WHERE` `ORDER BY` `LIMIT` `COUNT()`

**1. Retrieve all members and their cities**
```sql
SELECT first_name, surname, sex,
  (SELECT city FROM cities WHERE id = members.city_id) AS city
FROM members;
```

**2. List all restaurants in a specific city**
```sql
SELECT restaurant_name,
  (SELECT city FROM cities WHERE id = restaurant.city_id) AS restaurant_city
FROM restaurant
WHERE (SELECT city FROM cities WHERE id = restaurant.city_id) = 'City 1';
```

**3. Find all orders placed in the last 30 days**
```sql
SELECT * FROM orders
WHERE order_timestamp >= '2020-07-01'::date - INTERVAL '30 days';
```

**4. Show orders where total amount is greater than a specific value**
```sql
SELECT * FROM orders
WHERE total_order > 100;
```

**5. Display members sorted by surname**
```sql
SELECT * FROM members
ORDER BY surname ASC;
```

**6. Display the top 10 most recent orders**
```sql
SELECT * FROM orders
ORDER BY order_timestamp DESC
LIMIT 10;
```

**7. Find all restaurants of a specific type**
```sql
SELECT R.restaurant_name, T.restaurant_type
FROM restaurant R
JOIN restaurant_type T ON R.restaurant_type_id = T.id
WHERE T.restaurant_type = 'Asian';
```

**8. Count the total number of members**
```sql
SELECT COUNT(*) FROM members;
```

---

### 🟡 Level 2 — Aggregations & Grouping

**Skills:** `GROUP BY` `SUM()` `AVG()` `COUNT()` `HAVING`

**1. Total orders per member**
```sql
SELECT M.first_name, M.surname, COUNT(*) AS total_orders
FROM members M
JOIN orders O ON M.id = O.member_id
GROUP BY M.id, M.first_name, M.surname;
```

**2. Total revenue per restaurant**
```sql
SELECT R.restaurant_name, SUM(O.total_order) AS total_revenue
FROM restaurant R
JOIN orders O ON R.id = O.restaurant_id
GROUP BY R.id, R.restaurant_name;
```

**3. Average order value per member**
```sql
SELECT M.first_name, M.surname,
  ROUND(AVG(O.total_order), 2) AS avg_order_value
FROM members M
JOIN orders O ON M.id = O.member_id
GROUP BY M.id, M.first_name, M.surname;
```

**4. Top 5 restaurants by order count**
```sql
SELECT R.restaurant_name, COUNT(*) AS total_orders
FROM restaurant R
JOIN orders O ON R.id = O.restaurant_id
GROUP BY R.restaurant_name
ORDER BY total_orders DESC
LIMIT 5;
```

**5. Orders placed each day**
```sql
SELECT DATE(order_timestamp) AS order_day, COUNT(*) AS total_orders
FROM orders
GROUP BY DATE(order_timestamp)
ORDER BY order_day;
```

**6. Average monthly budget per city**
```sql
SELECT C.city, ROUND(AVG(M.monthly_budget), 2) AS avg_budget
FROM members M
JOIN cities C ON M.city_id = C.id
GROUP BY C.id, C.city
ORDER BY avg_budget;
```

---

### 🟠 Level 3 — Joining Tables

**Skills:** `INNER JOIN` `LEFT JOIN` Multiple table joins

**1. Member name, restaurant name and order amount**
```sql
SELECT M.first_name, M.surname, R.restaurant_name, O.total_order
FROM members M
JOIN orders O ON M.id = O.member_id
JOIN restaurant R ON R.id = O.restaurant_id;
```

**2. Which member ordered from which restaurant**
```sql
SELECT M.first_name, M.surname, R.restaurant_name
FROM members M
JOIN orders O ON M.id = O.member_id
JOIN restaurant R ON R.id = O.restaurant_id;
```

**3. Restaurants and total unique members who ordered**
```sql
SELECT R.restaurant_name, COUNT(DISTINCT M.id) AS total_members
FROM restaurant R
JOIN orders O ON R.id = O.restaurant_id
JOIN members M ON M.id = O.member_id
GROUP BY R.restaurant_name;
```

**4. Meal name, serve type and meal type**
```sql
SELECT M.meal_name, S.serve_type, T.meal_type
FROM meals M
JOIN meal_types T ON M.meal_type_id = T.id
JOIN serve_type S ON M.serve_type_id = S.id;
```

**5. Order details with meal name and price**
```sql
SELECT O.id, O.order_id, O.meal_id, M.meal_name, M.price
FROM meals M
JOIN order_details O ON M.id = O.meal_id;
```

---

### 🔵 Level 4 — Date & Time Analysis

**Skills:** `DATE_TRUNC()` `EXTRACT()` `CURRENT_DATE` Date arithmetic

**1. Orders placed each month**
```sql
SELECT EXTRACT(MONTH FROM order_timestamp) AS month,
  COUNT(*) AS total_orders
FROM orders
GROUP BY month
ORDER BY month;
```

**2. Peak ordering minutes of the day**
```sql
SELECT EXTRACT(MINUTE FROM order_timestamp) AS minute,
  COUNT(*) AS total_orders
FROM orders
GROUP BY minute
ORDER BY total_orders DESC;
```

**3. Members who haven't ordered in the last 60 days**
```sql
SELECT M.id, M.first_name, M.surname
FROM members M
WHERE M.id NOT IN (
  SELECT DISTINCT member_id FROM orders
  WHERE order_timestamp >= '2020-12-01'::date - INTERVAL '60 days'
);
```

**4. Total revenue per month**
```sql
SELECT EXTRACT(MONTH FROM O.order_timestamp) AS month,
  SUM(O.total_order) AS total_revenue
FROM restaurant R
JOIN orders O ON R.id = O.restaurant_id
GROUP BY month
ORDER BY month;
```

---

### 🟣 Level 5 — Conditional Logic & Segmentation

**Skills:** `CASE WHEN`

**1. Categorize orders by size**
```sql
SELECT *,
  CASE
    WHEN total_order < 20 THEN 'Small'
    WHEN total_order BETWEEN 20 AND 50 THEN 'Medium'
    ELSE 'Large'
  END AS order_category
FROM orders;
```

**2. Segment members by total spend**
```sql
SELECT M.id, M.first_name, M.surname,
  SUM(O.total_order) AS total_spend,
  CASE
    WHEN SUM(O.total_order) > 500 THEN 'High Value'
    WHEN SUM(O.total_order) BETWEEN 200 AND 500 THEN 'Medium Value'
    ELSE 'Low Value'
  END AS member_segment
FROM members M
JOIN orders O ON M.id = O.member_id
GROUP BY M.id, M.first_name, M.surname;
```

**3. Classify meals by price**
```sql
SELECT meal_name, price,
  CASE
    WHEN price < 20 THEN 'Budget'
    WHEN price BETWEEN 20 AND 50 THEN 'Standard'
    ELSE 'Premium'
  END AS meal_category
FROM meals;
```

**4. Label restaurants by commission**
```sql
SELECT *,
  CASE
    WHEN income_percentage < 5 THEN 'Low'
    WHEN income_percentage < 10 THEN 'Mid'
    ELSE 'High'
  END AS commission
FROM restaurant;
```

---

### 🔴 Level 6 — Subqueries

**Skills:** Subqueries `IN` `EXISTS` `NOT IN`

**1. Members who spent more than the average**
```sql
WITH member_spend AS (
  SELECT member_id, SUM(total_order) AS total_spend
  FROM orders GROUP BY member_id
)
SELECT M.id, M.first_name, M.surname, MS.total_spend
FROM members M
JOIN member_spend MS ON M.id = MS.member_id
WHERE MS.total_spend > (SELECT AVG(total_spend) FROM member_spend);
```

**2. Restaurants above average revenue**
```sql
SELECT * FROM restaurant
WHERE id IN (
  SELECT restaurant_id FROM orders
  GROUP BY restaurant_id
  HAVING SUM(total_order) > (
    SELECT AVG(total_spend) FROM (
      SELECT SUM(total_order) AS total_spend
      FROM orders GROUP BY restaurant_id
    ) AS restaurant_totals
  )
);
```

**3. Member with highest single order**
```sql
SELECT * FROM members
WHERE id IN (
  SELECT member_id FROM orders
  ORDER BY total_order DESC
  LIMIT 1
);
```

**4. Meals that have never been ordered**
```sql
SELECT * FROM meals
WHERE id NOT IN (
  SELECT meal_id FROM order_details
);
```

---

### 🟤 Level 7 — Window Functions

**Skills:** `ROW_NUMBER()` `RANK()` `DENSE_RANK()` `LAG()` `LEAD()`

**1. Rank restaurants by total revenue**
```sql
SELECT R.restaurant_name,
  SUM(O.total_order) AS total_revenue,
  RANK() OVER (ORDER BY SUM(O.total_order) DESC) AS revenue_rank
FROM orders O
JOIN restaurant R ON R.id = O.restaurant_id
GROUP BY R.restaurant_name;
```

**2. Top 3 restaurants per city**
```sql
SELECT * FROM (
  SELECT R.restaurant_name, C.city,
    COUNT(O.id) AS total_orders,
    ROW_NUMBER() OVER (
      PARTITION BY R.city_id
      ORDER BY COUNT(O.id) DESC
    ) AS rank
  FROM restaurant R
  JOIN orders O ON R.id = O.restaurant_id
  JOIN cities C ON R.city_id = C.id
  GROUP BY R.id, R.restaurant_name, R.city_id, C.city
) AS ranked
WHERE rank <= 3;
```

**3. Previous order amount per member using LAG**
```sql
SELECT id AS order_id, member_id, order_timestamp, total_order,
  LAG(total_order) OVER (
    PARTITION BY member_id ORDER BY order_timestamp
  ) AS previous_order
FROM orders;
```

**4. Difference between consecutive orders**
```sql
SELECT id AS order_id, member_id, order_timestamp, total_order,
  LAG(total_order) OVER (
    PARTITION BY member_id ORDER BY order_timestamp
  ) AS previous_order,
  total_order - LAG(total_order) OVER (
    PARTITION BY member_id ORDER BY order_timestamp
  ) AS difference
FROM orders;
```

**5. Member with highest spend per city**
```sql
WITH rank_per_city AS (
  SELECT M.id, M.first_name, M.surname, C.city,
    SUM(O.total_order) AS total_spend,
    ROW_NUMBER() OVER (
      PARTITION BY C.id ORDER BY SUM(O.total_order) DESC
    ) AS member_rank
  FROM members M
  JOIN orders O ON M.id = O.member_id
  JOIN cities C ON M.city_id = C.id
  GROUP BY M.id, M.first_name, M.surname, C.city, C.id
)
SELECT * FROM rank_per_city WHERE member_rank = 1;
```

---

### ⚫ Level 8 — Real Business Problems

**Skills:** CTEs, Window functions, Date arithmetic, Aggregations

**1. Top 10 most loyal members**
```sql
SELECT M.id, M.first_name, M.surname, COUNT(O.id) AS total_orders
FROM members M
JOIN orders O ON M.id = O.member_id
GROUP BY M.id, M.first_name, M.surname
ORDER BY total_orders DESC
LIMIT 10;
```

**2. Restaurants with declining order trends**
```sql
SELECT * FROM (
  SELECT R.restaurant_name,
    EXTRACT(MONTH FROM O.order_timestamp) AS month,
    SUM(O.total_order) AS current_orders,
    LEAD(SUM(O.total_order)) OVER (
      PARTITION BY R.id
      ORDER BY EXTRACT(MONTH FROM O.order_timestamp)
    ) AS next_month_orders
  FROM restaurant R
  JOIN orders O ON R.id = O.restaurant_id
  GROUP BY R.id, R.restaurant_name, EXTRACT(MONTH FROM O.order_timestamp)
) AS trends
WHERE next_month_orders < current_orders;
```

**3. Member with highest spend per month**
```sql
SELECT * FROM (
  SELECT M.id AS member_id, M.first_name, M.surname,
    EXTRACT(MONTH FROM order_timestamp) AS month,
    SUM(O.total_order) AS total_spend,
    ROW_NUMBER() OVER (
      PARTITION BY EXTRACT(MONTH FROM order_timestamp)
      ORDER BY SUM(O.total_order) DESC
    ) AS rnk
  FROM members M
  JOIN orders O ON M.id = O.member_id
  GROUP BY M.id, M.first_name, M.surname, EXTRACT(MONTH FROM order_timestamp)
) AS member_rank
WHERE rnk = 1;
```

**4. Customer Lifetime Value (CLV)**
```sql
SELECT M.id AS member_id, M.first_name, M.surname,
  SUM(O.total_order) AS lifetime_value
FROM members M
JOIN orders O ON M.id = O.member_id
GROUP BY M.id, M.first_name, M.surname
ORDER BY lifetime_value DESC;
```

**5. Members at risk of churn**
```sql
SELECT M.id AS member_id, M.first_name, M.surname
FROM members M
WHERE M.id NOT IN (
  SELECT DISTINCT member_id FROM orders
  WHERE order_timestamp >= '2020-07-31'::date - INTERVAL '90 days'
);
```

**6. Restaurant type generating most revenue**
```sql
SELECT RT.restaurant_type, SUM(O.total_order) AS total_revenue
FROM restaurant_type RT
JOIN restaurant R ON RT.id = R.restaurant_type_id
JOIN orders O ON R.id = O.restaurant_id
GROUP BY RT.restaurant_type
ORDER BY total_revenue DESC
LIMIT 1;
```

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|------|---------|
| PostgreSQL | Database engine |
| pgAdmin 4 | Database management & query tool |
| Python / Pandas | Data cleaning & preprocessing |
| GitHub | Version control & portfolio |

---

## 💡 Key Learnings

- **Foreign key constraints** require strict import ordering — parent tables must always be populated before child tables
- **Correlated subqueries** link inner queries to outer queries via matching IDs
- **Window functions** like `ROW_NUMBER()`, `RANK()`, `LAG()` and `LEAD()` are powerful for ranking and trend analysis without collapsing rows like `GROUP BY` does
- **CTEs** make complex multi-step queries far more readable than nested subqueries
- **`NOT IN` vs filtering** — detecting absence of data requires exclusion logic, not simple date filtering
- **`PARTITION BY`** resets window function rankings per group, essential for per-city or per-month analysis

---

## 👤 Author

Built as a portfolio SQL project to demonstrate progressive data analysis skills from basic querying to advanced business intelligence.

---

## 📜 License

This project is open source and available under the [MIT License](LICENSE).
