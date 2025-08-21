-- ========================================
-- Project: AtliQ Sales Data Analysis
-- Purpose: Data Cleaning, Anomaly Detection,
--          and Sales/Customer Insights
-- ========================================

USE AtliQ;

-- Inspect all tables
SELECT * FROM customers$;
SELECT * FROM date$;
SELECT * FROM [dbo].[markets$];
SELECT * FROM [dbo].[products$];
SELECT * FROM [dbo].[transactions$];

-- ========================================
-- DATA CLEANING
-- ========================================

-- 1. Check for NULL values in customers table
SELECT 
    SUM(CASE WHEN customer_code IS NULL THEN 1 ELSE 0 END) AS customer_code_nulls,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS customer_name_nulls,
    SUM(CASE WHEN customer_type IS NULL THEN 1 ELSE 0 END) AS customer_type_nulls
FROM customers$;

-- 2. Check for NULL values in date table
SELECT 
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN [cy-date] IS NULL THEN 1 ELSE 0 END) AS cydate_nulls,
    SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_nulls,
    SUM(CASE WHEN month_name IS NULL THEN 1 ELSE 0 END) AS month_nulls
FROM date$;

-- Remove unnecessary column
ALTER TABLE date$ DROP COLUMN date_yy_mmm;

-- 3. Check for NULL values in markets table
SELECT 
    SUM(CASE WHEN market_code IS NULL THEN 1 ELSE 0 END) AS marketcode_nulls,
    SUM(CASE WHEN markets_name IS NULL THEN 1 ELSE 0 END) AS marketname_nulls,
    SUM(CASE WHEN zone IS NULL THEN 1 ELSE 0 END) AS region_nulls
FROM markets$;

-- Found 2 NULLs in region → Remove those rows
DELETE FROM markets$ WHERE zone IS NULL;

-- 4. Check for NULL values in products table
SELECT 
    SUM(CASE WHEN product_code IS NULL THEN 1 ELSE 0 END) AS productcode_nulls,
    SUM(CASE WHEN product_type IS NULL THEN 1 ELSE 0 END) AS producttype_nulls
FROM products$;

-- 5. Check for NULL values in transactions table
SELECT 
    SUM(CASE WHEN product_code IS NULL THEN 1 ELSE 0 END) AS productcode_nulls,
    SUM(CASE WHEN customer_code IS NULL THEN 1 ELSE 0 END) AS customercode_nulls,
    SUM(CASE WHEN market_code IS NULL THEN 1 ELSE 0 END) AS marketcode_nulls,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS order_nulls,
    SUM(CASE WHEN sales_qty IS NULL THEN 1 ELSE 0 END) AS sales_nulls,
    SUM(CASE WHEN sales_amount IS NULL THEN 1 ELSE 0 END) AS amount_nulls,
    SUM(CASE WHEN currency IS NULL THEN 1 ELSE 0 END) AS currency_nulls
FROM transactions$;

-- Drop unnecessary temporary table
DROP TABLE [dbo].[transactions$_xlnm#_FilterDatabase];

-- ========================================
-- ANOMALY DETECTION & FIXES
-- ========================================

-- Identify invalid sales_amount entries

SELECT COUNT(sales_amount) AS zero_sales 
FROM transactions$ 
WHERE sales_amount = 0;   -- 1609 rows with sales_amount = 0

SELECT COUNT(sales_amount) AS negative_sales 
FROM transactions$ 
WHERE sales_amount < 0;   -- 2 rows with negative sales

-- Remove invalid sales records
DELETE FROM transactions$ WHERE sales_amount <= 0;

-- Check incorrect currency values
SELECT COUNT(currency) AS wrong_currency 
FROM transactions$ 
WHERE currency = 'USD';   -- 2 rows found

-- Fix currency to INR
UPDATE transactions$ 
SET currency = 'INR' 
WHERE currency = 'USD';

-- Verify cleaned transactions
SELECT * FROM transactions$;

-- ========================================
-- FINAL DATASET CREATION
-- ========================================

-- Create a unified view joining all relevant tables
CREATE VIEW sales_data AS 
    SELECT 
        t.sales_qty,
        t.sales_amount,
        t.currency,
        c.customer_name,
        c.customer_type,
        m.markets_name,
        m.zone,
        p.product_type,
        d.[cy-date],
        d.year,
        d.month_name
    FROM transactions$ t
    JOIN customers$ c ON t.customer_code = c.customer_code
    JOIN markets$ m ON t.market_code = m.market_code
    JOIN products$ p ON t.product_code = p.product_code
    JOIN date$ d ON t.order_date = d.date;

SELECT * FROM sales_data;

-- ========================================
-- SALES ANALYSIS
-- ========================================

-- 1. Total sales by region
SELECT markets_name, SUM(sales_amount) AS total_sales_by_region 
FROM sales_data
GROUP BY markets_name
ORDER BY total_sales_by_region DESC;
-- Delhi NCR has the highest sales, followed by Mumbai, Ahmedabad, Nagpur, and Bhopal.

-- 2. Total sales by customer
SELECT customer_name, SUM(sales_amount) AS total_sales_by_customer 
FROM sales_data
GROUP BY customer_name
ORDER BY total_sales_by_customer DESC;
-- Top customer: Electricalsara Stores
-- Bottom customer: Electricalsbea Stores

-- 3. Total sales by year
SELECT year, SUM(sales_amount) AS total_sales_by_year 
FROM sales_data
GROUP BY year;
-- Highest sales in 2018, lowest in 2017.

-- 4. Total sales by month
SELECT month_name, SUM(sales_amount) AS total_sales_by_month
FROM sales_data
GROUP BY month_name
ORDER BY total_sales_by_month;
-- September has the highest sales, March the lowest.

-- 5. Total sales by product type
SELECT product_type, SUM(sales_amount) AS total_sales_by_product 
FROM sales_data
GROUP BY product_type
ORDER BY total_sales_by_product DESC;
-- AtliQ’s own manufactured products outperform distributed products.

-- 6. Top 5 customers by revenue
SELECT TOP 5 
    customer_name,
    customer_type,
    SUM(sales_qty * sales_amount) AS revenue
FROM sales_data
GROUP BY customer_name, customer_type
ORDER BY revenue DESC;
-- Most top customers are from "Bricks & Mortar"; only one from E-commerce.

-- 7. Top 5 regions by revenue
SELECT TOP 5 
    markets_name,
    SUM(sales_qty * sales_amount) AS revenue_by_region
FROM sales_data
GROUP BY markets_name 
ORDER BY revenue_by_region DESC;

-- 8. Revenue by year
SELECT 
    year,
    SUM(sales_qty * sales_amount) AS revenue_by_year
FROM sales_data
GROUP BY year
ORDER BY revenue_by_year DESC;

-- 9. Revenue by month
SELECT 
    month_name,
    SUM(sales_qty * sales_amount) AS revenue_by_month
FROM sales_data
GROUP BY month_name
ORDER BY revenue_by_month DESC;

-- 10. Revenue contribution by product type
SELECT 
    product_type,
    SUM(sales_qty * sales_amount) AS revenue_by_product
FROM sales_data
GROUP BY product_type
ORDER BY revenue_by_product DESC;

-- ========================================
-- SEASONALITY ANALYSIS
-- ========================================

WITH seasonality AS (
    SELECT 
        sales_qty,
        sales_amount,
        CASE 
            WHEN month_name IN ('July','June','August') THEN 'Summer'
            WHEN month_name IN ('September','October','November') THEN 'Monsoon'
            WHEN month_name IN ('December','January','February') THEN 'Winter'
            ELSE 'Spring' 
        END AS season
    FROM sales_data
)
SELECT 
    season,
    SUM(sales_qty * sales_amount) AS revenue_per_season
FROM seasonality
GROUP BY season
ORDER BY revenue_per_season DESC;
-- Spring (March-May) is the best revenue season.

-- ========================================
-- CUSTOMER ANALYSIS
-- ========================================

-- 1. Active customers per year
SELECT year, COUNT(DISTINCT customer_name) AS active_customers
FROM sales_data
GROUP BY year
ORDER BY year;
-- Active customers peaked in 2017, but no new customers acquired after that.

-- 2. Cumulative customer acquisition
WITH first_year AS (
  SELECT customer_name, MIN(year) AS first_purchase_year
  FROM sales_data 
  GROUP BY customer_name
),
acq AS (
  SELECT first_purchase_year AS year, COUNT(*) AS new_customers
  FROM first_year 
  GROUP BY first_purchase_year
)
SELECT
  year,
  new_customers,
  SUM(new_customers) OVER (ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_customers
FROM acq
ORDER BY year;
-- 38 new customers acquired in 2017; no growth from 2018-2020.

-- 3. Year-over-year customer retention
WITH y AS (
  SELECT year, customer_name 
  FROM sales_data 
  GROUP BY year, customer_name
)
SELECT a.year AS base_year,
       COUNT(*) AS retained_next_year
FROM y a
JOIN y b
  ON b.year = a.year + 1 AND b.customer_name = a.customer_name
GROUP BY a.year
ORDER BY base_year;
-- Retention is 100% (all customers stayed), but acquisition is stagnant.

-- ========================================
-- INSIGHTS SUMMARY
-- ========================================
-- 1. Delhi NCR & Mumbai are key revenue drivers.
-- 2. Electricalsara Stores is the top customer; AtliQ’s own products dominate sales.
-- 3. Spring season is the most profitable.
-- 4. Customer base is loyal but stagnant since 2017.
-- 5. Strategy needed for new acquisitions to ensure growth.

