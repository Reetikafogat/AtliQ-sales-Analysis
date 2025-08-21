use AtliQ;
select * from customers$;
select * from date$;
select * from [dbo].[markets$]
select * from [dbo].[products$]
select * from [dbo].[transactions$]
--DATA CLEANING 
--Checking for nulls in all the columns of every table
select 
sum(case when customer_code is null then 1 else 0 end) as customer_code_nulls,
sum(case when customer_name is null then 1 else 0 end) as customer_name_nulls,
sum(case when customer_type is null then 1 else 0 end) as customer_type_nulls
from customers$

    
select 
sum(case when date is null then 1 else 0 end) as date_nulls,
sum(case when [cy-date] is null then 1 else 0 end) as cydate_nulls,
sum(case when year is null then 1 else 0 end) as year_nulls,
sum(case when month_name is null then 1 else 0 end) as month_nulls
from date$

alter table date$ drop column  date_yy_mmm

select 
sum(case when market_code is null then 1 else 0 end) as marketcode_nulls,
sum(case when markets_name is null then 1 else 0 end) as marketname_nulls,
sum(case when zone is null then 1 else 0 end) as region_nulls
from markets$
--2 nulls found in region 
delete from markets$ where zone is null

select 
sum(case when product_code is null then 1 else 0 end) as productcode_nulls,
sum(case when product_type is null then 1 else 0 end) as marketname_nulls
from products$

select 
sum(case when product_code is null then 1 else 0 end) as productcode_nulls,
sum(case when customer_code is null then 1 else 0 end) as customercode_nulls,
sum(case when market_code is null then 1 else 0 end) as marketcode_nulls,
sum(case when order_date is null then 1 else 0 end) as order_nulls,
sum(case when sales_qty is null then 1 else 0 end) as sales_nulls,
sum(case when sales_amount is null then 1 else 0 end) as amount_nulls,
sum(case when currency is null then 1 else 0 end) as currency_nulls
from transactions$

drop table [dbo].[transactions$_xlnm#_FilterDatabase]

--the data is cleaned and can be worked upon 
--DETECTING ANOMALIES 1609=0 values and 2 -ve value 
--we can see some of thedata valuers in sales amountn is 0 which cannot be possible for every sales there is a amount paid 
select count(sales_amount) as wrong_saleAmt  from  transactions$ where sales_amount=0;  
select count(sales_amount) as neg_saleAmt  from  transactions$ where sales_amount <0;  --sales amount can never be negative 

delete from transactions$ where sales_amount<=0 

select count(currency)as bad_currency  from transactions$ where currency='USD' --2 records found
--we need to change it to inr as we wrong currency here 

update  [transactions$] set  currency = 'INR' where currency ='USD'

select * from [transactions$]

--now we are done with cleaning part let's analyze 

create view sales_data AS 
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
    JOIN date$ d ON t.order_date = d.date


SELECT *
FROM sales_data;
-- now we have combined the data from different table and made a temp table which will help us analyze and trhis is ou final dataset on which we will work on 

SELECT markets_name, SUM(sales_amount) AS total_sales_by_region 
FROM sales_data
GROUP BY markets_name
ORDER BY total_sales_by_region DESC; --we can see in  delhi ncr  highest sales were made  and top 5 highest sale were in delhi ncr ,mumbai,ahmedabad nagpur and bhopal 

SELECT customer_name, SUM(sales_amount) AS total_sales_by_customer 
FROM sales_data
GROUP BY customer_name
ORDER BY total_sales_by_customer DESC;  -- highest sales by customer is by electricalsara stores followed by premium stores and excel stores 
--lowest salesby cutomer=electricalsbea stores followed by expression

SELECT year, SUM(sales_amount) AS total_sales_by_year 
FROM sales_data
GROUP BY year; --highest sale byb year in 2018 and then in 2019 lowest in 2017

SELECT month_name, SUM(sales_amount) AS total_sales_by_month
FROM sales_data
GROUP BY month_name
order by total_sales_by_month ; --september has the highest sales and march as the lowest

SELECT product_type, SUM(sales_amount) AS total_sales_by_product 
FROM sales_data
GROUP BY product_type
ORDER BY total_sales_by_product DESC; 
--the products which are manufactured by atliq itself  more selled as compared to the selling the product of others 


SELECT TOP 5 
    customer_name,
    customer_type,
    SUM(sales_qty * sales_amount) AS revenue
FROM sales_data
GROUP BY customer_name, customer_type
ORDER BY revenue DESC;
--  in top 5 customers mostly belong to customer type bricks and mortar and 1 from e-commerece 

--top 5 region for highest revenue 
SELECT TOP 5 
    markets_name,
    SUM(sales_qty * sales_amount) AS revenue_by_region
FROM sales_data
GROUP BY  markets_name 
ORDER BY revenue_by_region DESC;

-- revenue by year 
SELECT 
    year,
    SUM(sales_qty * sales_amount) AS revenue_by_year
FROM sales_data
GROUP BY  year
ORDER BY revenue_by_year DESC;

--revenue by month 
SELECT 
    month_name,
    SUM(sales_qty * sales_amount) AS revenue_by_month
FROM sales_data
GROUP BY  month_name
ORDER BY revenue_by_month DESC;

--revenue contribution by own brand or distribution
SELECT 
    product_type,
    SUM(sales_qty * sales_amount) AS revenue_by_product
FROM sales_data
GROUP BY  product_type
ORDER BY revenue_by_product DESC;

SELECT *
FROM sales_data;

--seosonality analysis 
with seasonality as ( select sales_qty,sales_amount ,
case when month_name in ('July','June','August') then 'Summer'
 when month_name in ('September','October','November') then 'Monsoon '
 when month_name in ('December','January','Feburary') then 'Winter'
else 'Spring' 
end as seasons from sales_data) 

SELECT 
    seasons,
    SUM(sales_qty * sales_amount) AS revenue_per_season
FROM seasonality
GROUP BY  seasons 
ORDER BY revenue_per_season DESC;
-- spring (i.e. march,april,may) is the best season for revenue 

--customer acquisition over time.

-- Active customers per year (who bought that year)
SELECT year, COUNT(DISTINCT customer_name) AS active_customers
FROM sales_data
GROUP BY year
ORDER BY year;

-- Cumulative customer base over time
WITH first_year AS (
  SELECT customer_name, MIN(year) AS first_purchase_year
  FROM sales_data GROUP BY customer_name
),
acq AS (
  SELECT first_purchase_year AS year, COUNT(*) AS new_customers
  FROM first_year GROUP BY first_purchase_year
)
SELECT
  year,
  new_customers,
  SUM(new_customers) OVER (ORDER BY year
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_customers
FROM acq
ORDER BY year;

-- Simple year-over-year retention (customers who bought in both Y and Y+1)
WITH y AS (
  SELECT year, customer_name FROM sales_data GROUP BY year, customer_name
)
SELECT a.year AS base_year,
       COUNT(*) AS retained_next_year
FROM y a
JOIN y b
  ON b.year = a.year + 1 AND b.customer_name = a.customer_name
GROUP BY a.year
ORDER BY base_year;
--“The analysis shows that the company had 38 active customers acquired in 2017, and no new customers were added from 2018 to 2020. 
--While customer retention is exceptionally high at 100%, the lack of new acquisitions suggests stagnation in customer base growth.

--This may indicate reliance on a fixed set of loyal customers, and expansion strategies may be needed for long-term growth.”
