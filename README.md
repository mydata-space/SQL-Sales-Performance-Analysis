# Sales Performance Analysis 

## Project Overview

My main goal for this project was to uncover key trends, evaluate performance, and find actionable insights to guide busniss strategic decision.
The dataset includes approximately 60,000 sales records, 18,500 customers, and 130 products, from from 2010 to 2014. 

### Data Loading Procedure: Direct CSV file parsing into SQL tables. 

### Tools & Skills: SQL (Aggregations, Window Functions, CTEs, Subqueries)

## Key Questions & Analysis

### 1. Revenue Trend Analysis
- Goal: Understand sales performance over time.
- Method: Aggregated total sales by year and month.
- Finding: Revenue fluctuated significantly, peaking in 2013. A notable plunge occurred in 2014, marking it and 2010 as the lowest-performing years. 
A strong correlation was observed between sales volume and the number of active customers.

### 2. Cumulative Revenue Analysis
- Goal: Visualize the progression of sales accumulation within each year.
- Method: Utilized window functions to calculate a running total of sales by month.
- Finding: This analysis provided a clear view of sales momentum and helped identify seasonal trends and growth patterns throughout each fiscal year.

### 3. Year-over-Year Performance Analysis
- Goal: Compare current performance against historical benchmarks.
- Method: Compared monthly and yearly revenue to: The same period in the previous year (YoY Growth) and the annual average revenue.
- Finding: This highlighted periods of outperformance and decline, offering a nuanced view of growth beyond raw totals.

### 4. Product Contribution Analysis
- Goal: Determine which products and regions drive the most value.
- Method: Calculated the percent contribution of each product category to total sales, both globally and broken down by country.
- Finding: The business is overwhelmingly reliant on a single category:	Bikes(96.46%) , Accessories(2.39%) and Clothing(1.16%).
This indicates a significant diversification risk.

### 5. Product & Customer Segmentation
- Product Segmentation by Cost: Segmented products into cost ranges (Low, Medium, High).
- Finding: The vast majority of products (82) are low-cost. Fewer products (39) are high-cost, and very few (9) fall into a medium-cost range, suggesting a polarized product pricing strategy.
- Customer Segmentation: Segmented customers based on their purchase history (e.g., New, Regular, VIP).

## Finding 
The customer base is heavily skewed toward new customers (14,629), with a much smaller proportion of regular and VIP customers. This suggests the company is effective at customer acquisition but may have challenges with customer retention and loyalty.

## Conclusion & Business Implications

- Revenue Volatility:
The significant sales plunge in 2014 requires immediate investigation into potential causes (e.g., market conditions, operational issues).
- Product Diversification Risk:
The extreme reliance on bike sales presents a major strategic risk. Initiatives to grow the Accessories and Clothing categories are crucial for long-term stability.
- Customer Retention:
The high volume of new customers versus retained customers suggests potential inefficiency. A cost-benefit analysis of customer acquisition vs. retention spending is recommended to optimize marketing strategies and improve customer lifetime value.

## Suggestions
The data reveals a company at a crossroads. To ensure future growth, it must address two core vulnerabilities:
- Putting all eggs in one basket: The total reliance on bike sales is a major risk.  
- Leaking customers: The company is great at getting customers in but not at keeping them coming back. Investigate on retention strategies and customer loyalty programs immediately.
