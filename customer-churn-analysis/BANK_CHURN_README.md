# Bank Customer Churn Analysis

## Project Overview
This project analyzes customer churn behavior at a bank using a real-world dataset of 10,000 customers. The goal was to identify which customer segments are most at risk of leaving the bank, using a series of 15 business questions answered entirely in PostgreSQL.

The dataset was clean on import — no preprocessing or data cleaning was required before loading into pgAdmin.

---

## Dataset
- **Source:** [Kaggle — Churn for Bank Customers](https://www.kaggle.com/datasets/mathchi/churn-for-bank-customers)
- **Rows:** 10,000 customers
- **Schema:** Single table (bank_churn)

### Table Schema
```sql
CREATE TABLE bank_churn (
    row_number        INT,
    customer_id       INT,
    surname           VARCHAR(50),
    credit_score      INT,
    geography         VARCHAR(20),
    gender            VARCHAR(10),
    age               INT,
    tenure            INT,
    balance           NUMERIC(12,2),
    num_of_products   INT,
    has_cr_card       INT,
    is_active_member  INT,
    estimated_salary  NUMERIC(12,2),
    exited            INT
);
```
> `exited` is the churn flag — 1 = customer left the bank, 0 = customer stayed

---

## Business Questions

| # | Question | SQL Concept |
|---|---|---|
| Q1 | What is the overall churn rate of the bank? | Aggregation, Subquery |
| Q2 | How many customers are there per country, and what is the churn rate in each country? | GROUP BY, Conditional Aggregation |
| Q3 | What is the churn rate by gender? | GROUP BY, Conditional Aggregation |
| Q4 | What is the average credit score, balance, and estimated salary for churned vs retained customers? | GROUP BY, AVG |
| Q5 | Which age group has the highest churn rate? | CASE WHEN, Conditional Aggregation |
| Q6 | Do customers with more products churn more? | GROUP BY, Conditional Aggregation |
| Q7 | What is the churn rate for active vs inactive members, broken down by country? | Multi-column GROUP BY, CASE WHEN |
| Q8 | Do customers with a credit card churn less than those without one? | CASE WHEN, Conditional Aggregation |
| Q9 | Rank churned customers by balance within each country — who were the highest value customers lost? | DENSE_RANK, PARTITION BY, WHERE filter |
| Q10 | What is the churn rate by tenure bucket? Which tenure group is most at risk? | CASE WHEN buckets, Conditional Aggregation |
| Q11 | What percentage of churned customers had a credit card and were inactive? | Multi-condition CASE WHEN, Subquery denominator |
| Q12 | Among customers with a balance of 0, what is the churn rate? | Conditional Aggregation, Subset denominator |
| Q13 | For each country, what is the average balance of churned vs retained customers, and the difference? | AVG with CASE WHEN, Arithmetic in SELECT |
| Q14 | Rank the top 10 customers by credit score within each geography — how many churned? | DENSE_RANK, Subquery, PARTITION BY |
| Q15 | Build a customer risk profile by age group, number of products, and active membership status | CTE, Multi-dimension GROUP BY, Conditional Aggregation |

---

## Key Findings

**Overall Churn Rate**
The bank lost **20.37%** of its customers — roughly 1 in 5 customers exited.

**Churn by Country**
Germany had the highest churn rate at **32.44%**, significantly above France and Spain. German customers are nearly twice as likely to churn as customers in other regions, suggesting a potential market-specific retention problem worth investigating further.

**Churn by Gender**
Female customers churned at a higher rate (**25.07%**) compared to male customers. This gap warrants a deeper look at whether product offerings or customer experience differs meaningfully by gender.

**Churn by Age Group**
The "Old" age group (46-60) had the highest churn rate at **51.12%** — more than half of customers in this bracket left the bank. This is a significant finding as older customers typically hold higher balances, making them high-value customers to retain.

**Churn by Number of Products**
Customers with 3 or 4 products showed extremely high churn rates (up to 100% for 4-product holders), though these groups are small in volume. Customers with 1-2 products make up the bulk of the customer base and show more moderate churn — suggesting customers with too many products may be oversold and dissatisfied.

**Highest Risk Segment (Q15)**
The highest risk customer profiles were:
- **Old + High Spender + Inactive** — 100% churn rate (60 customers)
- **Really Old + High Spender + Inactive** — 100% churn rate (10 customers)

Inactive members who hold multiple products and are in the older age brackets represent the bank's most at-risk segment. Targeted retention campaigns for this group could have an outsized impact on overall churn reduction.

---

## SQL Concepts Demonstrated
- Conditional aggregation: `CASE WHEN` inside `COUNT` and `AVG`
- Churn rate calculations with correct denominator logic
- Window functions: `DENSE_RANK()`, `PARTITION BY`
- Subqueries for filtered denominators
- CTEs for multi-dimension segmentation
- `GROUP BY` across multiple dimensions
- Age and product bucketing with `CASE WHEN`

---

## How to Run
1. Download the dataset from the Kaggle link above
2. Create the table using the schema provided
3. Import the CSV into pgAdmin
4. Run the queries from `bank_churn_analysis.sql`

---

## Author
**Ajala Boluwatife Oluwanifemi**
LinkedIn: [Ajala Boluwatife](https://www.linkedin.com/in/ajala-boluwatife-2b2854316)
Portfolio: [SQL Projects](https://github.com/AjalaBolu/SQL-PROJECTS)
