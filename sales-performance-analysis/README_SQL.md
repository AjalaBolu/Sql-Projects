# Sales Performance Analysis — SQL

Part of the **Sales Performance Analysis** portfolio project (Phase 1: Data Analysis Foundations).
Database: PostgreSQL. Dataset: [Sample Superstore](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final) (Kaggle).

## What this covers

- Loading a raw CSV into PostgreSQL on Windows
- Designing a normalized schema (staging → customers / products / orders)
- Handling real data-quality issues (encoding, permissions, conflicting IDs)
- 15 analysis queries covering revenue, profit, margin, customers, and trends

## Setup

1. Create the `sales` staging table and load the raw CSV (see `superstore_setup.sql` for the full commented script).
2. Import gotchas handled in the script:
   - **Encoding**: the raw CSV contains non-breaking spaces (`0xA0`) that break a plain UTF-8 import. Fixed with `ENCODING 'LATIN1'` on the import.
   - **Permissions**: `COPY` runs server-side and gets blocked by Windows file permissions. Fixed by using `\copy` instead, which runs client-side.
3. Split the staging table into three normalized tables: `customers`, `products`, `orders`.

## Schema design decisions

- **Location fields (city/state/postal_code/region) live on `orders`, not `customers`.** Initial design put them on `customers`, but the data showed the same `customer_id` shipping to different cities/states (e.g. one customer with orders in both Minneapolis, MN and San Francisco, CA). Location is a property of the *order* (shipping destination), not a fixed attribute of the customer.
- **Deduplication uses `ROW_NUMBER()`, not `DISTINCT`.** Some `customer_id`s and `product_id`s have conflicting values across rows (name/category variants). A plain `DISTINCT` insert throws a primary key violation in that case — `ROW_NUMBER() OVER (PARTITION BY id ORDER BY row_id)` picks one canonical row per ID instead.
- **`row_id` is the primary key on `orders`**, not `order_id` — an order can span multiple product line items, so `order_id` isn't unique on its own.

## Key metric corrections

- `sales` is already total line-item revenue (price × quantity) — don't multiply by `quantity` again.
- Profit margin is a ratio: `SUM(profit) / SUM(sales)`, not raw summed profit.
- Order counts must use `COUNT(DISTINCT order_id)`, since `orders` has one row per line item, not per order.

## Queries included (15 total)

1–3. Revenue, profit, and order count by region
4–6. Top/bottom 10 products by profit, and products with negative profit
7–8. Month-over-month sales and profit trend
9. Profit margin by category / sub-category
10–11. Top 10 customers by sales and by profit
12. Sales & profit by customer segment
13. Average discount vs. profit margin (does discounting hurt margin?)
14. Ship mode breakdown — order count and average delivery time
15. Year-over-year revenue growth (using `LAG()`)

## Notable insight

The **Tables** sub-category (Furniture) shows strong sales but a **negative profit margin** — a recurring finding in this dataset, likely driven by heavy discounting. Worth flagging as a pricing/discount policy issue in the write-up.

## Files

- `superstore_setup.sql` — full commented setup script (staging table, load, normalization)
- Analysis queries — see task list above; run against `orders` / `customers` / `products`
