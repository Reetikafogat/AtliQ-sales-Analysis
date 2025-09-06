# AtliQ-sales-Analysis
This repository contains the analysis of the Atliq Hardware sales dataset, focusing on revenue trends, customer behavior, product performance, and market growth, with actionable recommendations for improving business performance.

💼 Problem Statement:
Atliq Technologies, a global hardware company, has observed fluctuations in its sales and revenue across different markets and customer segments. Despite steady product launches and expansion into new regions, management is concerned about why certain markets are underperforming while others are showing growth, and why some products drive significant revenue while others lag behind. The company wants to analyze its historical sales data to uncover patterns in customer behavior, market performance, and product demand. This analysis will help Atliq identify key revenue drivers, understand reasons for declining sales in specific regions or product lines, and make data-driven decisions for future business strategy.

Solution: to solve this business problem I did data Analysis using Sql and then visualized ,created report to find patterns and insights useful for the Company.

📂 Dataset
Source: Kaggle – Atliq Hardware Sales Dataset
The daraset consists of 5 tables:
Customers : stores the information of customers
Dates : stores the dates
Markets : stores the information of various regional offices 
Products : stores the information of the products
Transactions :Contains sales amount, quantity sold, dates, and links to products, customers, and markets.

✅ SQL Analysis Process
🔍 Data Inspection:
All key tables (customers$, date$, markets$, products$, transactions$) were explored to ensure completeness and correctness before any transformation.

<img width="1472" height="760" alt="Screenshot 2025-09-03 034612" src="https://github.com/user-attachments/assets/7f0b80f1-8c3c-4446-b6da-4d2fc5aebcb9" />

🧹 Data Cleaning:

Checked for NULL values in each table and handled them accordingly:
Removed rows with missing regions from markets$.
Dropped unnecessary columns from date$.
Handled missing values in products and customer datasets.
Verified transaction data for completeness.

🔍 Anomaly Detection & Correction:

Identified and removed invalid transactions:
1609 rows with zero sales amount and 2 rows with negative sales were removed.
Corrected incorrect currency entries by updating ‘USD’ to ‘INR’.
Ensured data consistency across tables.

🗂 Final Dataset Creation:
Created a unified view sales_data that joins transaction data with customer, product, market, and date details.
This view forms the foundation for analysis in Power BI.

📊 Sales Analysis

Region Analysis: 
Delhi NCR and Mumbai are the highest contributors.

Customer Analysis:
Electricalsara Stores is the top-performing customer.

Temporal Analysis:

Highest sales in 2018; lowest in 2017.
September leads in monthly sales.

Product Analysis:

AtliQ’s own products outperform distributed ones.
Top 5 segments: Customers and regions driving maximum revenue.

🌦 Seasonality Analysis:

Sales peak during Spring (March-May).
Seasonal trends highlight the need for targeted promotions.

👥 Customer Insights:

Active customers peaked in 2017 and remained stagnant afterward.
Cumulative acquisition halted after 2017.
Customer retention is strong (100%), but new customer acquisition has stopped.

✅ Key Findings from Power BI

1. Revenue Trends:

Sales have varied over time, with certain months and regions contributing disproportionately to total revenue.

Bengaluru and Bhubaneswar stand out as high ASP regions, indicating a premium customer base or better-priced products.

<img width="1402" height="818" alt="main Kpi and insights" src="https://github.com/user-attachments/assets/28bcba22-eb0a-41bb-92fc-cf09ae7e253d" />

2. Product Performance:

A few top products contribute a large percentage of revenue, highlighting the importance of product mix management.

The Average Selling Price (ASP) analysis reveals pricing disparities across products and regions.

<img width="1394" height="806" alt="image" src="https://github.com/user-attachments/assets/1920b4a3-2c64-46e5-b21a-24de20d26e3b" />

3. Growth Analysis:

Month-over-Month (MoM) growth fluctuates, with some months showing sharp increases and others declines.

Year-over-Year (YoY) growth highlights seasonal effects and helps identify expanding or shrinking markets.

<img width="1394" height="805" alt="image" src="https://github.com/user-attachments/assets/60764337-df30-43d0-84f9-fdfdd0bd94cc" />


4. ASP Insights:

Certain regions show high ASP but low quantity sold, suggesting niche or premium products.

Other regions have low ASP but high sales volumes, indicating bulk or discount-driven purchases.

<img width="1386" height="791" alt="image" src="https://github.com/user-attachments/assets/1adce8b5-14e6-44bb-9cff-ac92ace02808" />

✅ Insights Derived from SQL Analysis & Power BI Report

Key Markets:
Delhi NCR and Mumbai are the biggest revenue contributors — strategic focus should be maintained here.

Customer Loyalty but Stagnation:
Customers are loyal, but no new customers have been acquired after 2017 → growth depends on attracting new customers.

Seasonality Matters:
Spring is the most profitable season → stock planning and marketing campaigns should align with these months.

Product Portfolio:
AtliQ’s own products are leading in sales → further investment in proprietary products is recommended.

Pricing and ASP Insights:
ASP varies by region → premium and budget strategies can be customized for each market.

Need for Strategic Action:
Without new customer acquisition, the company risks plateauing → marketing campaigns, referrals, and e-commerce expansion should be considered.

🟢 Business Recommendations

Invest in customer acquisition strategies such as online outreach, referral programs, and loyalty rewards.
Optimize inventory and pricing by focusing on high ASP regions and ensuring products are available during peak seasons.
Expand product lines where distribution channels are weak to balance revenue growth.
Tailor campaigns for regions showing lower ASP but higher sales volume → explore discount structures or bundled offerings.





