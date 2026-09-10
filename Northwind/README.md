# Northwind SQL Practice — Window Functions, CTEs & Real Findings

A targeted SQL practice project built on the classic **Northwind** database, focused on strengthening window functions, multi-step CTE logic, self-joins, and conditional aggregation — areas flagged as growth points after a run of earlier SQL portfolio projects (Netflix, Zomato, Amazon, Bank Customer Churn, NYC Taxi, Olist, Coffee Sales, Spotify+YouTube).

This isn't just a task list — every query was run against the live database, and the findings below are pulled directly from the actual output.

## About the Dataset

Northwind is a small, well-known e-commerce dataset used widely for teaching SQL. Core tables used in this project:

- **customers** — client companies placing orders
- **orders** — one row per order, linked to a customer and an employee
- **order_details** — line items per order (one order can have many products)
- **products** — product catalog, linked to a category
- **categories** — product category names
- **employees** — staff who handled orders

Join path: `customers → orders → order_details → products → categories`, with `employees` joining directly to `orders`. An ERD (`northwind_erd.mermaid`) is included alongside this README.

## Skills Practiced

- **Window functions:** `RANK`, `DENSE_RANK`, `LAG`, `LEAD`, running totals via `SUM() OVER()`, rolling averages with explicit frame clauses (`ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`), `FIRST_VALUE`/`LAST_VALUE` (including the default-frame gotcha with `LAST_VALUE`), and `NTILE` for quartile bucketing
- **CTEs:** staged aggregate-then-window logic, multi-CTE chains for "true across every row in a group" checks (via `MIN()` on a binary flag), rank-then-filter patterns for top-N-per-group queries
- **Joins:** self-contained join chains across up to 5 tables, `LEFT JOIN` + `IS NULL` for anti-join ("never ordered") logic
- **Conditional aggregation:** `CASE WHEN` inside `COUNT`/`AVG`/`SUM`, careful denominator selection for percentage calculations
- **Safe division:** `NULLIF` to guard against divide-by-zero

## Key Findings

Across all customers, orders in this dataset total **$1,265,793.04** in revenue.

### Revenue is concentrated in two categories (Task 2)

| Category | Revenue | Share |
|---|---|---|
| Beverages | $267,868.18 | 21.2% |
| Dairy Products | $234,507.28 | 18.5% |
| Confections | $167,357.23 | 13.2% |
| Meat/Poultry | $163,022.36 | 12.9% |
| Seafood | $131,261.74 | 10.4% |
| Condiments | $106,047.08 | 8.4% |
| Produce | $99,984.58 | 7.9% |
| Grains/Cereals | $95,744.59 | 7.6% |

Beverages and Dairy Products alone account for **nearly 40% of all revenue**, despite being 2 of 8 categories.

### Discounting is fairly consistent across categories (Task 3)

Average discount (among discounted line items only) ranges narrowly from **13% (Condiments)** to **16% (Beverages)** — no category stands out as being discounted dramatically more or less than the others, suggesting discounting isn't being used as a category-specific lever.

### Revenue is heavily concentrated among a small group of customers (Task 4)

Of 89 customers, the top 3 alone generated over **$319,000** — roughly a quarter of all revenue:

| Rank | Customer | Total Revenue |
|---|---|---|
| 1 | Horst Kloss | $110,277.31 |
| 2 | Roland Mendel | $104,874.98 |
| 3 | Jose Pavarotti | $104,361.95 |
| 4 | Paula Wilson | $51,097.80 |
| 5 | Patricia McKenna | $49,979.91 |

There's a steep cliff after the top 3 — #4 (Paula Wilson) generated less than half of what #3 did. At the bottom end, Francisco Chang placed a single order worth just **$100.80** — the definition of a one-time, low-value customer (worth cross-referencing against Task 21's "one-time customer" list).

### One product dominates its entire category (Task 5)

Most categories have a fairly gradual drop-off from their #1 to #2 product — except Beverages, where **Côte de Blaye ($141,396.74)** outsold the #2 beverage (Ipoh Coffee, $23,526.70) by **six times**. That single product accounts for over half of all Beverage revenue on its own.

Top product per category:

| Category | Top Product | Revenue |
|---|---|---|
| Beverages | Côte de Blaye | $141,396.74 |
| Dairy Products | Raclette Courdavault | $71,155.70 |
| Meat/Poultry | Thüringer Rostbratwurst | $80,368.67 |
| Confections | Tarte au sucre | $47,234.97 |
| Grains/Cereals | Gnocchi di nonna Alice | $42,593.06 |
| Produce | Manjimup Dried Apples | $41,819.65 |
| Seafood | Carnarvon Tigers | $29,171.87 |
| Condiments | Vegie-spread | $16,701.10 |

### Order handling is unevenly distributed among staff (Task 6)

Margaret Peacock handled **156 orders** — nearly 4x as many as the lowest performer (Steven Buchanan, 42). The top 3 employees (Margaret Peacock, Janet Leverling, Nancy Davolio) together handled more orders than the bottom 6 combined.

### Germany and the USA are the strongest markets (Task 7)

Looking at each country's top customer: **Horst Kloss (Germany, $110,277.31)** and **Jose Pavarotti (USA, $104,361.95)** are the two highest-value individual customers company-wide. Germany also has the deepest customer base overall (11 customers), followed by the USA and France (10 each).

### Order cadence varies wildly by customer (Task 8)

Gaps between a customer's consecutive orders range from **same-day repeat orders** (e.g., Elizabeth Lincoln placed two orders both dated 1997-01-10 — a 0-day gap) to **over a year of inactivity** (Alejandra Camino went 532 days between a September 1996 order and her next in March 1998). Most customers fall somewhere in between, typically reordering every 20–60 days — but the long tail of dormant-then-reactivated customers is worth flagging for a churn/win-back analysis in a future project.

### Order volume grew steadily, then dropped off at the data's edge (Task 9)

Monthly order counts show a clear growth trend — from **22 orders in July 1996** to a peak of **74 orders in April 1998**. May 1998 shows only 14 orders, which is almost certainly a **partial month** (the dataset cuts off early in May) rather than a genuine business decline — worth noting so this final data point isn't misread as a downturn.

### Revenue growth mirrors order growth, with heavy month-to-month swings (Task 10)

Company-wide revenue climbed from **$27,861.90 (July 1996)** to **$123,798.68 (April 1998)** — roughly a 4.4x increase over 22 months. Along the way, % changes swing dramatically (e.g., -37% in Feb 1997, +64% in Dec 1997), reflecting Northwind's relatively low order volume per month — a handful of large orders can swing the whole month's total significantly. The -85% drop in May 1998 is the same partial-month artifact flagged in Task 9, not a real collapse.

### Individual order values are highly volatile — few customers trend consistently upward (Task 11)

Flagging each order as "Increased" or "Decreased" relative to a customer's previous order shows **no clear monotonic pattern** for almost anyone — most customers bounce between increases and decreases order to order, sometimes by huge swings (e.g., Roland Mendel's order value swung from $1,792.00 to $8,623.45 — a nearly 5x jump — then back down to $550.59 the very next order). This strongly suggests that **Task 20 (customers with strictly increasing monthly spend)** will return a very short list, if any — worth confirming once that query is run, since it reframes what "growth" looks like at the individual level versus the smooth company-wide trend in Task 10.

## Task List (30 Tasks)

1. Rank customers by total revenue overall (RANK vs DENSE_RANK)
2. Total revenue per product category
3. Average discount given per product category (among discounted line items)
4. Rank customers by total revenue overall
5. Rank products by total revenue within each category
6. Rank employees by number of orders handled
7. Within each country, rank customers by total revenue
8. Days between each customer's consecutive orders (LAG)
9. Month-over-month change in total order count, company-wide
10. Month-over-month % change in total revenue, company-wide
11. Flag whether each order increased or decreased vs the customer's previous order
12. Running total of revenue per customer over time
13. Running total of company-wide revenue by month
14. Rolling 3-order average order value per customer
15. Running count of orders per customer
16. Each customer's first and most recent order date
17. Each customer's single highest-value order
18. Customers bucketed into quartiles by lifetime spend (NTILE)
19. Products bucketed into quartiles by revenue, per category
20. Customers whose spend increased every consecutive month they ordered
21. One-time customers (exactly one order ever)
22. Products that have never been ordered
23. Top 3 products by revenue within each category
24. % of order line items with a discount, per category
25. Average order value: discounted vs non-discounted orders, per category
26. Late shipment rate (%) per employee
27. Total revenue and unique customers served, per employee
28. Best-selling product (by quantity) per shipping country
29. Customers who have ordered from every product category
30. Revenue per unit of stock remaining, per product

## Key SQL Learnings

- **Aggregate before you window.** Postgres won't let a window function wrap an aggregate directly (e.g. `LAG(SUM(...))`) in the same pass — the aggregate has to be staged in a CTE first, then the window function applied on top of the aggregated rows.
- **`LAST_VALUE` needs an explicit frame.** With only `ORDER BY` and no frame clause, the default frame (`RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`) silently makes `LAST_VALUE` return the *current* row's value instead of the partition's true last value. Fix: `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`.
- **Window functions can't be filtered directly in `WHERE`.** Any "top N per group" or "rank = 1" task needs the rank computed in one CTE and filtered in an outer query.
- **`MIN()`/`MAX()` on a binary flag is a clean way to check "always true" or "ever true" across a group** — e.g. `MIN(is_increase) = 1` confirms a condition held for *every* row in a group, not just some.
- **Line items vs. distinct orders/entities is a recurring denominator trap.** Joining in a one-to-many table (like `order_details`) without `DISTINCT` where needed silently inflates counts.
- **Discount fields store a fraction taken off, not a fraction paid** — the correct revenue formula is `unit_price * quantity * (1 - discount)`, not a subtraction.
- **`NULLIF(column, 0)` guards divisions from a divide-by-zero error** by swapping the offending zero for `NULL`, letting the row resolve to `NULL` instead of crashing the query.
- **Company-wide aggregates can hide individual-level volatility.** Task 10's smooth upward revenue trend and Task 11's noisy, non-monotonic individual order patterns describe the exact same underlying data — a reminder that aggregate trends don't necessarily reflect what's happening at the entity level.

## Tools

PostgreSQL via pgAdmin.
