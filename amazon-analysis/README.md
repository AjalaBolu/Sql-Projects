# 🛒 Amazon E-Commerce Advanced SQL Project

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue?logo=postgresql)
![SQL](https://img.shields.io/badge/SQL-Advanced-orange)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

**Author:** Ajala Bolu  
**Tool:** PostgreSQL + pgAdmin  
**Difficulty:** Intermediate / Advanced  

---

## 📌 Project Overview

This project analyses over **21,000 rows** of real-world e-commerce data modelled after Amazon's platform. Using PostgreSQL, I worked through 11 business problems covering revenue analysis, customer behaviour, product performance, seller metrics, and logistics — progressing from foundational aggregations to advanced window functions, CTEs, and conditional aggregation.

---

## 🗂️ Database Schema

The database consists of **9 interrelated tables:**

| Table | Description |
|---|---|
| `category` | Product categories |
| `customers` | Registered customer accounts |
| `sellers` | Third-party seller accounts |
| `products` | Product catalogue with pricing and cost (COGS) |
| `orders` | Order headers — one row per order |
| `order_items` | Line items within each order |
| `payments` | Payment records and statuses per order |
| `shippings` | Shipment and delivery status per order |
| `inventory` | Stock levels per product per warehouse |

### Entity Relationship Diagram

```
CATEGORY ──< PRODUCTS ──< ORDER_ITEMS >── ORDERS >── CUSTOMERS
                  │                           │
              INVENTORY                   PAYMENTS
                                          SHIPPINGS
                                          SELLERS
```

---

## 🧰 SQL Concepts Used

- `JOIN` across multiple tables (up to 5-way joins)
- Aggregate functions: `SUM`, `COUNT`, `AVG`, `ROUND`
- Window functions: `DENSE_RANK`, `ROW_NUMBER`, `RANK`, `LAG`
- Common Table Expressions (CTEs)
- Subqueries in `WHERE` and `SELECT` clauses
- Conditional aggregation with `CASE WHEN` inside `SUM` / `COUNT`
- `HAVING` for post-aggregation filtering
- `EXTRACT` for date-based grouping
- `TRIM` for data quality handling
- `CONCAT` for computed columns
- PostgreSQL `::NUMERIC` casting for `ROUND()`

---

## 📊 Business Problems & Solutions

---

### 1. Top Selling Products

**Goal:** Identify the top 10 products by total sales value including quantity sold.

```sql
SELECT 
    p.product_name,
    SUM(o.quantity)                    AS quantity_sold,
    SUM(o.quantity * o.price_per_unit) AS total_sales
FROM products p
JOIN order_items o ON p.product_id = o.product_id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;
```

**Key learning:** `SUM(quantity * price_per_unit)` is required — `SUM(price_per_unit)` ignores quantity and `COUNT(quantity)` counts rows, not units.

---

### 2. Revenue by Category

**Goal:** Total revenue per category with each category's percentage contribution to overall revenue.

```sql
SELECT 
    c.category_name,
    SUM(o.quantity * o.price_per_unit)                              AS total_revenue,
    ROUND(
        SUM(o.quantity * o.price_per_unit) * 100.0 /
        (SELECT SUM(quantity * price_per_unit) FROM order_items)
    ::NUMERIC, 2)                                                   AS revenue_pct
FROM category c
JOIN products p   ON c.category_id = p.category_id
JOIN order_items o ON p.product_id = o.product_id
GROUP BY 1
ORDER BY 2 DESC;
```

**Key learning:** Multiply by 100 *before* rounding to avoid precision loss on small values. PostgreSQL `ROUND()` requires `::NUMERIC` cast on `FLOAT` columns.

---

### 3. Average Order Value (AOV)

**Goal:** Average order value per customer — only customers with more than 5 orders.

```sql
WITH cte AS (
    SELECT 
        o.customer_id,
        c.first_name,
        ROUND(AVG(oi.quantity * oi.price_per_unit)::NUMERIC, 2) AS aov
    FROM customers c
    JOIN orders o      ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id IN (
        SELECT customer_id
        FROM orders
        GROUP BY 1
        HAVING COUNT(*) > 5
    )
    GROUP BY 1, 2
    ORDER BY 3 DESC
)
SELECT * FROM cte;
```

**Key learning:** `IN` subqueries must return exactly one column. `HAVING` filters after `GROUP BY` — the clause order is always `GROUP BY → HAVING → ORDER BY`.

---

### 4. Monthly Sales Trend

**Goal:** Monthly revenue totals with current month vs previous month comparison.

```sql
WITH monthly_sales AS (
    SELECT 
        EXTRACT(YEAR  FROM o.order_date)                         AS year,
        EXTRACT(MONTH FROM o.order_date)                         AS month,
        ROUND(SUM(oi.quantity * oi.price_per_unit)::NUMERIC, 2)  AS current_month_sale
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY 1, 2
    ORDER BY 1, 2
)
SELECT
    year,
    month,
    current_month_sale,
    LAG(current_month_sale, 1) OVER (ORDER BY year, month) AS last_month_sale
FROM monthly_sales;
```

**Key learning:** `LAG(column, 1)` looks back one row. The CTE is necessary because `LAG` cannot operate on a `GROUP BY` aggregation in the same query layer — you must compute aggregates first, then apply window functions on top.

---

### 5. Customers with No Purchases

**Goal:** Find customers who registered but never placed an order.

```sql
SELECT 
    customer_id,
    first_name,
    last_name,
    state,
    CURRENT_DATE AS today
FROM customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM orders
)
ORDER BY customer_id;
```

**Key learning:** `NOT IN` with a subquery is the correct pattern for "records that don't exist in another table." `WHERE` subqueries do not need aliases — that rule applies only to `FROM` subqueries.

---

### 6. Least-Selling Categories by State

**Goal:** The single worst-performing product category in each state by total sales.

```sql
WITH cte AS (
    SELECT 
        cu.state,
        c.category_name,
        SUM(oi.quantity * oi.price_per_unit)              AS total_sales,
        RANK() OVER (
            PARTITION BY cu.state 
            ORDER BY SUM(oi.quantity * oi.price_per_unit) ASC
        )                                                 AS rnk
    FROM category c
    JOIN products p    ON c.category_id = p.category_id
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o      ON oi.order_id = o.order_id
    JOIN customers cu  ON o.customer_id = cu.customer_id
    GROUP BY 1, 2
)
SELECT 
    state,
    category_name,
    ROUND(total_sales::NUMERIC, 2) AS total_sales
FROM cte
WHERE rnk = 1
ORDER BY state;
```

**Key learning:** `RANK()` is preferred over `ROW_NUMBER()` here because tied categories both deserve to appear. `PARTITION BY state` resets the ranking for each state. Window functions on aggregates must be layered in a CTE.

---

### 7. Customer Lifetime Value (CLTV)

**Goal:** Total spend per customer over their lifetime, ranked by value.

```sql
WITH cte AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name)                  AS full_name,
        ROUND(SUM(oi.quantity * oi.price_per_unit)::NUMERIC, 2) AS cltv
    FROM customers c
    JOIN orders o      ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY 1, 2
)
SELECT 
    customer_id,
    full_name,
    cltv,
    DENSE_RANK() OVER (ORDER BY cltv DESC) AS rnk
FROM cte
ORDER BY rnk;
```

**Key learning:** `DENSE_RANK()` is the right choice for CLTV ranking — it handles ties without skipping rank numbers, unlike `RANK()`. No `PARTITION BY` is needed when ranking all customers globally.

---

### 8. Inventory Stock Alerts

**Goal:** Flag products by stock level (Low / Medium / High).

```sql
WITH stk AS (
    SELECT 
        p.product_name,
        p.price,
        i.last_stock_date,
        CASE 
            WHEN stock < 31 THEN 'Low Stock'
            WHEN stock < 55 THEN 'Medium Stock'
            ELSE 'High Stock'
        END AS stk_alert
    FROM inventory i
    JOIN products p ON i.product_id = p.product_id
)
SELECT product_name, price, last_stock_date, stk_alert
FROM stk
WHERE stk_alert = 'Low Stock';
```

**Key learning:** `WHERE` cannot filter on a `SELECT` alias because `WHERE` executes before `SELECT` in SQL's logical order. A CTE wraps the `CASE` first, making the alias available to `WHERE` in the outer query.

---

### 9. Payment Success Rate

**Goal:** Percentage breakdown of all orders by payment status.

```sql
SELECT 
    payment_status,
    COUNT(*)                                                           AS total_count,
    ROUND(
        (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM payments))::NUMERIC
    , 2)                                                               AS percentage
FROM payments
GROUP BY 1
ORDER BY 2 DESC;
```

**Key learning:** A scalar subquery in the `SELECT` clause computes the grand total once and divides each group's count against it — a clean single-query approach that avoids needing a CTE.

---

### 10. Most Returned Products

**Goal:** Top 10 products by return count with return rate as a percentage of units sold.

```sql
WITH returns AS (
    SELECT 
        p.product_id,
        p.product_name,
        COUNT(*)                                             AS total_returns,
        SUM(oi.quantity)                                     AS total_sold,
        ROUND(
            (COUNT(*) * 100.0 / SUM(oi.quantity))::NUMERIC
        , 2)                                                 AS return_rate
    FROM shippings s
    JOIN orders o       ON s.order_id = o.order_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p     ON oi.product_id = p.product_id
    WHERE TRIM(s.delivery_status) = 'Returned'
    GROUP BY 1, 2
)
SELECT 
    product_id,
    product_name,
    total_returns,
    total_sold,
    return_rate,
    DENSE_RANK() OVER (ORDER BY total_returns DESC) AS rnk
FROM returns
ORDER BY rnk
LIMIT 10;
```

**Key learning:** Raw data had a trailing space in `'Returned '` — `TRIM()` was required to match correctly. Filtering inside the CTE (`WHERE` before `GROUP BY`) is more efficient than filtering in the outer query.

---

### 11. Top Performing Sellers

**Goal:** Top 5 sellers by total sales with order success rate breakdown.

```sql
WITH tps AS (
    SELECT 
        s.seller_id,
        s.seller_name,
        COUNT(DISTINCT o.order_id)                                         AS total_orders,
        COUNT(DISTINCT CASE WHEN o.order_status = 'Completed' 
                            THEN o.order_id END)                           AS successful_orders,
        ROUND(SUM(oi.quantity * oi.price_per_unit)::NUMERIC, 2)            AS total_sales
    FROM sellers s
    JOIN orders o       ON s.seller_id = o.seller_id
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY 1, 2
)
SELECT 
    seller_name,
    total_orders,
    successful_orders,
    total_sales,
    ROUND(
        (successful_orders * 100.0 / total_orders)::NUMERIC
    , 2)                                                                    AS success_pct,
    DENSE_RANK() OVER (ORDER BY total_sales DESC)                           AS rnk
FROM tps
ORDER BY rnk
LIMIT 5;
```

**Key learning:** Conditional aggregation — `COUNT(CASE WHEN condition THEN id END)` — counts only rows matching the condition, with NULL returned for non-matches (which `COUNT` ignores automatically). This avoids subqueries and keeps all status breakdowns in a single pass.

---

## 💡 Key Learnings

| Concept | Lesson |
|---|---|
| `SUM` vs `COUNT` | `COUNT(numeric_col)` counts rows; `SUM(numeric_col)` totals values |
| SQL execution order | `FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT` |
| `ROUND()` in PostgreSQL | Requires `::NUMERIC` cast — won't accept `DOUBLE PRECISION` |
| Window functions on aggregates | Must layer in a CTE — can't `RANK()` on `SUM()` in the same query |
| `RANK` vs `DENSE_RANK` | `DENSE_RANK` handles ties without skipping numbers |
| `LAG(col, 1)` | Looks back 1 row — essential for period-over-period trend analysis |
| `HAVING` placement | Always after `GROUP BY`, never before |
| `WHERE` on aliases | Impossible — use a CTE to expose the alias to an outer `WHERE` |
| Dirty data | `TRIM()` fixes trailing/leading spaces that silently break `WHERE` filters |
| Conditional aggregation | `SUM(CASE WHEN ... END)` filters within an aggregate without a subquery |

---

## 🚀 How to Run

```bash
# 1. Create the database
CREATE DATABASE amazon_db;

# 2. Run the schema file
psql -d amazon_db -f amazon_db_schema.sql

# 3. Import CSVs in FK order:
# category → customers → sellers → products →
# orders → order_items → payments → shippings → inventory

# 4. Verify row counts
SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;
```

---

## 📁 Repository Structure

```
amazon-sql-project/
├── amazon_db_schema.sql     # All CREATE TABLE statements
├── queries/
│   ├── 01_top_selling_products.sql
│   ├── 02_revenue_by_category.sql
│   ├── 03_average_order_value.sql
│   ├── 04_monthly_sales_trend.sql
│   ├── 05_customers_no_purchases.sql
│   ├── 06_least_selling_by_state.sql
│   ├── 07_customer_lifetime_value.sql
│   ├── 08_inventory_stock_alerts.sql
│   ├── 09_payment_success_rate.sql
│   ├── 10_most_returned_products.sql
│   └── 11_top_performing_sellers.sql
└── README.md
```

---

*Built as part of a progressive SQL portfolio — from Netflix → Zomato → Amazon e-commerce.*
