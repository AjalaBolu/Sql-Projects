CREATE TABLE bank_churn (
    row_number       INT,
    customer_id      INT,
    surname          VARCHAR(50),
    credit_score     INT,
    geography        VARCHAR(20),
    gender           VARCHAR(10),
    age              INT,
    tenure            INT,
    balance           NUMERIC(12,2),
    num_of_products   INT,
    has_cr_card       INT,
    is_active_member  INT,
    estimated_salary  NUMERIC(12,2),
    exited            INT
);

-- Q1: What is the overall churn rate of the bank?
-- (percentage of customers who exited)
select 
	count(*) as total_churn ,
	round(count(exited) * 100.0 / (select count(*) from bank_churn),2) as percentage
from bank_churn
where exited = 1;

-- Q2: How many customers are there per country,
-- and what is the churn rate in each country?

select 
	geography,
	count(*) as total_coustomers,
	count(case when exited = 1 then exited end) as ttl_exited,
	ROUND(COUNT(CASE WHEN exited = 1 THEN 1 END) * 100.0 / COUNT(*), 2) AS churn_rate_percentage
from bank_churn
group by 1;

-- Q3: What is the churn rate by gender?

select 
	gender,
	count (*) as total_gender,
	count(case when exited = 1 then exited end) as ttl_exited,
	round(count(case when exited = 1 then exited end) * 100.0 / count(*),2) as percentage
from bank_churn
group by 1;

-- Q4: What is the average credit score, balance, and estimated salary
-- for churned vs retained customers?

select
	exited,
	round(avg(credit_score),2) as avg_credit_score,
	round(avg(balance),2) as avg_balance,
	round(avg(estimated_salary),2) as avg_es_sal
from bank_churn
group by 1;

-- Q5: Which age group has the highest churn rate?
-- (bucket ages: 18-30, 31-45, 46-60, 60+)
select 
	case 
		when age between 18 and 30 then 'young'
		when age between 31 and 45 then 'mid'
		when age between 46 and 60 then 'old'
		else 'really old'
		end as age_buckets,
	count(*) as total_coustomers,
	count(case when exited = 1 then exited end) as churned_customers,
	round(count(case when exited = 1 then exited end) * 100.0 / count(*),2) as percentage
from bank_churn
group by 1
order by 4 desc;

-- Q6: Do customers with more products churn more?
-- Show churn rate by number of products held.

select 
	num_of_products,
	count(*) as ttl,
	count(case when exited = 1 then exited end) as churned_customers,
	round(count(case when exited = 1 then exited end) * 100.0 / count(*),2) as percentage
from bank_churn
group by 1
order by 1;

-- Q7: What is the churn rate for active members vs inactive members,
-- broken down by country?
select 
	geography,
	CASE WHEN is_active_member = 1 THEN 'Active' ELSE 'Inactive' END AS membership_status,
	count(*) as total_coustomers,
	count(case when exited = 1 then exited end) as churned_customers,
	round(count(case when exited = 1 then exited end) * 100.0 / count(*),2) as percentage
from bank_churn
group by 1,2
order by 1;

-- Q8: Do customers with a credit card churn less than those without one?
select 
	case when has_cr_card = 1 then 'Has cr' else 'Doesnt have cr' end as credit_card_status,
	count(*) as total_coustomers,
	count(case when exited = 1 then exited end) as churned_customers,
	round(count(case when exited = 1 then exited end) * 100.0 / count(*),2) as percentage
from bank_churn
group by 1;

-- Q9: Rank customers who churned by their balance within each country —
-- who were the highest value customers the bank lost?

SELECT 
   surname,
   geography,
   balance,
   DENSE_RANK() OVER (PARTITION BY geography ORDER BY balance DESC)
FROM bank_churn
WHERE exited = 1;

-- Q10: What is the churn rate by tenure bucket
-- (0-2 years, 3-5 years, 6-8 years, 9-10 years)?
-- Which tenure group is most at risk?

select 
	case 
	WHEN tenure BETWEEN 0 AND 2 THEN '0-2 years'
	WHEN tenure BETWEEN 3 AND 5 THEN '3-5 years'
	WHEN tenure BETWEEN 6 AND 8 THEN '6-8 years'
	ELSE '9-10 years'
	end as tenure_bracket,
	count(*) as total_coustomers,
	count(case when exited = 1 then exited end) as churned_customers,
	round(count(case when exited = 1 then exited end) * 100.0 / count(*),2) as percentage
from bank_churn
group by 1
order by 4 desc;

-- Q11: What percentage of churned customers had a credit card
-- and were inactive members?

select 
	count(*) as total_coustomers,
	count(case when exited = 1 then exited end) as churned_customers,
	round(count(case when exited = 1 and has_cr_card = 1 and is_active_member = 0 then exited end) * 100.0 / COUNT(CASE WHEN exited = 1 THEN 1 END), 2) as percentage
from bank_churn



-- Q12: Among customers with a balance of 0, what is the churn rate?
-- Does having no balance predict churn?

select 
	count(case when exited = 1 and balance = 0 then exited end) as churned_customers,
	round(count(case when exited = 1 and balance = 0 then exited end) * 100.0 / count(case when balance = 0 then exited end),2) as percentage
from bank_churn;

-- Q13: For each country, what is the average balance of churned vs retained customers,
-- and what is the difference between the two?

SELECT
    geography,
     round(avg ( case when exited = 1 then balance end ),2) as churned,
    round(avg ( case when exited = 0 then balance end ),2) as stayed,
   round(avg ( case when exited = 1 then balance end ) - avg ( case when exited = 0 then balance end),2) as differene
FROM bank_churn
GROUP BY 1;

-- Q15: Build a customer risk profile — segment customers by age group,
-- number of products, and active membership status.
-- Show churn rate for each combination. Which segment is the highest risk?-- Q1: What is the overall churn rate of the bank?
-- (percentage of customers who exited)
WITH brackets AS (
    SELECT 
        CASE 
            WHEN age BETWEEN 18 AND 30 THEN 'Young'
            WHEN age BETWEEN 31 AND 45 THEN 'Mid'
            WHEN age BETWEEN 46 AND 60 THEN 'Old'
            ELSE 'Really Old'
        END AS age_buckets,
        CASE
            WHEN num_of_products BETWEEN 1 AND 2 THEN 'Low Spender'
            ELSE 'High Spender'
        END AS product_grouped,
        CASE 
            WHEN is_active_member = 1 THEN 'Active' 
            ELSE 'Inactive' 
        END AS membership_status,
        exited
    FROM bank_churn
)
SELECT
    age_buckets,
    product_grouped,
    membership_status,
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN exited = 1 THEN 1 END) AS churned,
    ROUND(COUNT(CASE WHEN exited = 1 THEN 1 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM brackets
GROUP BY 1,2,3
ORDER BY churn_rate DESC;


-- ============================================
-- PERCENTAGE CALCULATIONS USED IN THIS PROJECT
-- ============================================

-- 1. OVERALL CHURN RATE (Q1)
-- Numerator: churned customers (filtered by WHERE exited = 1)
-- Denominator: every customer in the table
-- Answers: out of all customers, what % left the bank
-- ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_churn), 2)

-- ============================================

-- 2. CHURN RATE WITHIN A GROUP (Q2, Q3, Q6, Q7, Q8, Q10, Q15)
-- Numerator: churned customers in that group
-- Denominator: all customers in that group (because of GROUP BY)
-- Answers: within each segment (country, gender, age bucket etc), what % churned
-- ROUND(COUNT(CASE WHEN exited = 1 THEN 1 END) * 100.0 / COUNT(*), 2)

-- ============================================

-- 3. CHURN RATE AMONG A SPECIFIC SUBSET (Q12)
-- Numerator: churned customers with balance = 0
-- Denominator: all customers with balance = 0
-- Answers: among zero-balance customers specifically, what % churned
-- ROUND(COUNT(CASE WHEN exited = 1 AND balance = 0 THEN 1 END) * 100.0 / COUNT(CASE WHEN balance = 0 THEN 1 END), 2)

-- ============================================

-- 4. PERCENTAGE OF CHURNED CUSTOMERS MEETING EXTRA CONDITIONS (Q11)
-- Numerator: churned customers who also had a credit card AND were inactive
-- Denominator: all churned customers only
-- Answers: out of churned customers specifically, what % had both conditions
-- ROUND(COUNT(CASE WHEN exited = 1 AND has_cr_card = 1 AND is_active_member = 0 THEN 1 END) * 100.0 / COUNT(CASE WHEN exited = 1 THEN 1 END), 2)

-- ============================================
-- CORE RULE: pattern is always numerator * 100.0 / denominator
-- what changes each time is WHO you are measuring (numerator)
-- and WHAT you are measuring against (denominator)
-- getting the denominator right is the most important decision
-- in every percentage calculation
-- ============================================