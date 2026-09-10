# Pizza Sales SQL Analysis

Business-question-driven SQL analysis of a pizza restaurant's sales data, written in PostgreSQL (adapted from an MS SQL Server / T-SQL tutorial).

## Dataset

- **Table:** `pizza` (renamed from `pizza_sales`)
- **Rows:** 48,620 line items
- **Source:** `pizza_sales_excel_file.xlsx`
- **Tool:** PostgreSQL / pgAdmin

| Column | Type | Description |
|---|---|---|
| `pizza_id` | INTEGER (PK) | Unique line-item ID |
| `order_id` | INTEGER | Groups multiple pizzas into one order |
| `pizza_name_id` | VARCHAR | SKU-like code (name + size) |
| `quantity` | INTEGER | Qty of that pizza in the order |
| `order_date` | DATE | |
| `order_time` | TIME | |
| `unit_price` | NUMERIC(10,2) | Price per pizza |
| `total_price` | NUMERIC(10,2) | `unit_price * quantity` |
| `pizza_size` | VARCHAR | S / M / L / XL / XXL |
| `pizza_category` | VARCHAR | Classic / Veggie / Supreme / Chicken |
| `pizza_ingredients` | TEXT | Comma-separated ingredient list |
| `pizza_name` | VARCHAR | Full display name |

## Setup

```sql
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

ALTER TABLE pizza_sales RENAME TO pizza;
```

Data loaded via `COPY ... CSV HEADER` from a UTF-8 cleaned CSV export of the source Excel file.

---

## Business Questions & Findings

### Q1. What is the total revenue for all pizzas?
```sql
SELECT 
    SUM(total_price) AS total_revenue
FROM pizza;
```
**Total revenue: $817,860.05**

### Q2. What is the average order value?
```sql
SELECT
    SUM(total_price) / COUNT(DISTINCT order_id) AS avg_order_value
FROM pizza;
```
**Average order value: $38.31**

### Q3. What is the total quantity of pizzas sold?
```sql
SELECT 
    SUM(quantity) AS total_pizza_sold
FROM pizza;
```
**Total pizzas sold: 49,574**

### Q4. What is the total number of orders placed?
```sql
SELECT 
    COUNT(DISTINCT order_id) AS total_orders
FROM pizza;
```
**Total orders: 21,350**

### Q5. What is the average number of pizzas per order?
```sql
SELECT 
    SUM(quantity)::NUMERIC / COUNT(DISTINCT order_id) AS avg_pizza_per_order
FROM pizza;
```
**Average pizzas per order: 2.32**

> Note: `SUM(quantity) / COUNT(DISTINCT order_id)` without a `::NUMERIC` cast silently truncates to integer division in PostgreSQL (returns `2` instead of `2.32`).

### Q6. Daily trend of orders by day of week
```sql
SELECT 
    TO_CHAR(order_date, 'Day') AS dow,
    COUNT(DISTINCT order_id) AS total_orders
FROM pizza
GROUP BY TO_CHAR(order_date, 'Day'), EXTRACT(DOW FROM order_date)
ORDER BY EXTRACT(DOW FROM order_date);
```
| Day | Total Orders |
|---|---|
| Sunday | 2,624 |
| Monday | 2,794 |
| Tuesday | 2,973 |
| Wednesday | 3,024 |
| Thursday | 3,239 |
| Friday | 3,538 |
| Saturday | 3,158 |

**Friday** is the busiest day; **Sunday** is the slowest. Orders trend upward from Sunday through Friday, then dip slightly on Saturday.

### Q7. Monthly trend of orders
```sql
SELECT 
    TO_CHAR(order_date, 'Month') AS month,
    COUNT(DISTINCT order_id) AS total_orders
FROM pizza
GROUP BY TO_CHAR(order_date, 'Month'), EXTRACT(MONTH FROM order_date)
ORDER BY EXTRACT(MONTH FROM order_date);
```
| Month | Total Orders |
|---|---|
| January | 1,845 |
| February | 1,685 |
| March | 1,840 |
| April | 1,799 |
| May | 1,853 |
| June | 1,773 |
| July | 1,935 |
| August | 1,841 |
| September | 1,661 |
| October | 1,646 |
| November | 1,792 |
| December | 1,680 |

**July** is the peak month; **October** is the slowest. Order volume is fairly stable year-round, mostly in the 1,700–1,900 range.

### Q8. Percentage of sales by pizza category
```sql
SELECT 
    pizza_category,
    SUM(total_price) AS total_revenue,
    ROUND(SUM(total_price) * 100 / (SELECT SUM(total_price) FROM pizza), 2) AS pct_of_total_revenue
FROM pizza
GROUP BY 1;
```
| Category | Total Revenue | % of Total |
|---|---|---|
| Classic | $220,053.10 | 26.91% |
| Supreme | $208,197.00 | 25.46% |
| Chicken | $195,919.50 | 23.96% |
| Veggie | $193,690.45 | 23.68% |

Revenue is fairly evenly spread across categories; **Classic** leads at nearly 27%.

### Q9. Percentage of sales by pizza size
```sql
SELECT 
    pizza_size,
    SUM(total_price) AS total_revenue,
    ROUND(SUM(total_price) * 100 / (SELECT SUM(total_price) FROM pizza), 2) AS pct
FROM pizza
GROUP BY 1;
```
| Size | Total Revenue | % of Total |
|---|---|---|
| L | $375,318.70 | 45.89% |
| M | $249,382.25 | 30.49% |
| S | $178,076.50 | 21.77% |
| XL | $14,076.00 | 1.72% |
| XXL | $1,006.60 | 0.12% |

**Large** pizzas dominate revenue at nearly 46%. XL/XXL are niche, together under 2% of revenue.

### Q10. Total pizzas sold by category
```sql
SELECT 
    pizza_category,
    SUM(quantity) AS total_sold
FROM pizza
GROUP BY 1
ORDER BY 2 DESC;
```
| Category | Total Pizzas Sold |
|---|---|
| Classic | 14,888 |
| Supreme | 11,987 |
| Veggie | 11,649 |
| Chicken | 11,050 |

**Classic** leads in volume too — consistent with its revenue lead in Q8.

### Q11. Top 5 best-selling pizzas by quantity sold
```sql
SELECT
    pizza_name,
    SUM(quantity) AS total_sold
FROM pizza
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```
| Pizza | Total Sold |
|---|---|
| The Classic Deluxe Pizza | 2,453 |
| The Barbecue Chicken Pizza | 2,432 |
| The Hawaiian Pizza | 2,422 |
| The Pepperoni Pizza | 2,418 |
| The Thai Chicken Pizza | 2,371 |

Top 5 are tightly clustered — no runaway favorite, demand spread evenly.

### Q12. Bottom 5 pizzas by quantity sold
```sql
SELECT
    pizza_name,
    SUM(quantity) AS total_sold
FROM pizza
GROUP BY 1
ORDER BY 2 ASC
LIMIT 5;
```
| Pizza | Total Sold |
|---|---|
| The Brie Carre Pizza | 490 |
| The Mediterranean Pizza | 934 |
| The Calabrese Pizza | 937 |
| The Spinach Supreme Pizza | 950 |
| The Soppressata Pizza | 961 |

**The Brie Carre Pizza** is the weakest seller by a wide margin — roughly half the volume of the next-lowest pizza. Strong candidate for menu review.

---

## Key Takeaways

- **$817,860.05** total revenue across **21,350 orders** (avg. order value **$38.31**, avg. **2.32 pizzas/order**).
- **Classic** category leads in both revenue (26.91%) and volume (14,888 units).
- **Large** size drives revenue (45.89%); XL/XXL are negligible (<2% combined).
- **Friday** is the busiest day; **July** is the busiest month — order volume otherwise fairly stable.
- **The Brie Carre Pizza** significantly underperforms and is the clearest menu-trim candidate.

## Tools

- PostgreSQL, pgAdmin
- Python/Pandas (CSV cleanup prior to import)
