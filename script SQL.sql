/*
 ***********************************************************
	OVERVIEW 
 ***********************************************************
	- TABLE SALES 60398 RECORDS 
	- TABLE CUSTOMERS 18484 RECORDS
	- TABLE PRODUCT 130 RECORDS
	- WE FILTER EACH DATA BASE ON QUESTION TO AVOID INCONSISTENT REGISTRATIONS 
*/

SELECT * FROM [dbo].[gold.fact_sales];
SELECT * FROM [dbo].[gold.dim_customers];
SELECT * FROM [dbo].[gold.report_products];

/*
 ***********************************************************
 REVENUE TREND ANALYSIS 
 ***********************************************************
*/

-- CHANGE OVER TIME : MEASURE (TOTAL SALES) BY THE DIMENSIONS DATE(YEARS,MONTHS)

SELECT 
	YEAR(order_date),
	-- MONTH(order_date),
	SUM(sales_amount)
FROM [dbo].[gold.fact_sales]
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date) -- , MONTH(order_date)
ORDER BY 2 DESC;
-- -------------

SELECT
	YEAR(order_date) Years,
	-- MONTH(order_date) Months,
	SUM(sales_amount) Total_Sales -- ,
	-- SUM (quantity) Total_Quantity
	-- COUNT(DISTINCT customer_key) Total_Customers,
	-- COUNT(DISTINCT order_number) Total_Orders
FROM [gold.fact_sales]
WHERE YEAR(order_date) IS NOT NULL
GROUP BY YEAR(order_date) -- , MONTH(order_date) 
ORDER BY 1 ; 
/* 
	THE REVENUE FLUACTUATED OVER THE YEAR AND PLUNGE IN 2014. THE BIGGEST SALES AMOUNT 
	ACCOUNTED FOR THE YEAR 2013 FOLLOWED BY 2011 AND 2012. 2014 AND 2010 REGISTRED
	VERY LOW SALES AMOUNT OVER THE FIVE YEARS PERIOD. AT THE SAME PERIOD THERE IS A 
	CORRELATION BETWEEN SALES AMOUNT AND TOTAL CUSTOMERS NUMBERS.
*/


/*
 ***********************************************************
 REVENUE CUMULATIVE ANALYSIS 
 ***********************************************************
*/

-- THE PROGRESSION OF CUMULATIVE SALES OVER THE MONTH

SELECT
	YEARS, MONTHS, TOTAL_SALE,
	SUM(TOTAL_SALE) OVER(PARTITION BY YEARS ORDER BY MONTHS) AS ROLLING_TOTAL_SALE
FROM (
	SELECT 
		YEAR(order_date) AS YEARS,
		MONTH(order_date) AS MONTHS,
		SUM(sales_amount) AS TOTAL_SALE
	FROM [dbo].[gold.fact_sales]
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(order_date), MONTH(order_date)
	) REVENUE_TRENDS
ORDER BY 1 ;

/*
 ***********************************************************
 PERFORMANCE ANALYSIS 
 ***********************************************************
*/

-- COMPARING CURRENT REVENUE VS PY REVENUE AND THE AVERAGE REVENUE OF THE YEAR
WITH PERFORMANCE AS
(
	SELECT 
		YEAR(order_date) AS YEARS,
		MONTH(order_date) AS MONTHS,
		SUM(sales_amount) AS TOTAL_SALE
	FROM [dbo].[gold.fact_sales]
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(order_date),MONTH(order_date)
)
SELECT 
	*,
	AVG(TOTAL_SALE) OVER(PARTITION BY YEARS) AS AVERAGE_GLOBAL_REVENUE,
	CASE 
	WHEN TOTAL_SALE > AVG(TOTAL_SALE) OVER(PARTITION BY YEARS) THEN 'ABOVE THE AVG'
	ELSE 'BELOW THE AVG'
	END REVENUE_VS_AVG,
	LAG(TOTAL_SALE) OVER(PARTITION BY YEARS ORDER BY MONTHS) AS PY_REVENUE,
	CASE 
	WHEN LAG(TOTAL_SALE) OVER(PARTITION BY YEARS ORDER BY MONTHS) IS NULL THEN NULL
	WHEN TOTAL_SALE > LAG(TOTAL_SALE) OVER(PARTITION BY YEARS ORDER BY MONTHS) THEN 'INCREASE'
	ELSE 'DECREASE'
	END MOM_REVENUE
FROM PERFORMANCE 
ORDER BY YEARS, MONTHS ;

-- COMPARING THE YEARLY PERFROMANCE SALES OF PRODUCT CATEGORY WITH THE AVG_SALE 
-- AND PREVIOUS YEAR SALES PERFORMANCE 

WITH Performance AS
(
	SELECT 
	YEAR(s.order_date) Years, p.category,
	SUM(s.sales_amount) Current_Sales
	FROM [gold.fact_sales] s
	LEFT JOIN [gold.report_products] p
		ON s.product_key = p.product_key
	WHERE YEAR(s.order_date) IS NOT NULL
	GROUP BY YEAR(s.order_date), p.category
) 
SELECT 
	Years, category, Current_Sales,
	AVG(Current_Sales) OVER(PARTITION BY category) AVG_Sales,
	Current_Sales - AVG(Current_Sales) OVER(PARTITION BY category) Variance,
	CASE 
		WHEN Current_Sales > AVG(Current_Sales) OVER(PARTITION BY category) THEN 'Above the Average'
		WHEN Current_Sales < AVG(Current_Sales) OVER(PARTITION BY category) THEN 'Below the Average'
		ELSE 'Average'
	END Decision,
	LAG(Current_Sales) OVER(PARTITION BY category ORDER BY Years) PY_Sales,
	Current_Sales - LAG(Current_Sales) OVER(PARTITION BY category ORDER BY Years) Variance_PY,
	CASE 
		WHEN Current_Sales > LAG(Current_Sales) OVER(PARTITION BY category ORDER BY Years) THEN 'Increase'
		WHEN Current_Sales < LAG(Current_Sales) OVER(PARTITION BY category ORDER BY Years) THEN 'Decrease'
		ELSE 'N/A'
	END Decision
FROM Performance 
ORDER BY category, Years;

/*
 ***********************************************************
 PERCENT CONTRIBUTION ANALYSIS 
 ***********************************************************
*/

-- WHAT IS THE REVENUE PERCENT CONTRIBUTION OF EACH PRODUCT CATEGORY BY THE COUNTRY
WITH JOIN_TABLE AS
(
	SELECT 
		c.country,p.category,
		SUM(s.sales_amount) AS TOTAL_SALE
	FROM [dbo].[gold.fact_sales] s
	LEFT JOIN [dbo].[gold.report_products] p
		ON s.product_key = p.product_key
	LEFT JOIN [dbo].[gold.dim_customers] c
		ON s.customer_key = c.customer_key
		WHERE c.country != 'n/a'
	GROUP BY c.country,p.category 
)
SELECT *,
SUM(TOTAL_SALE) OVER(PARTITION BY country) AS TOTAL_SALE_COUNTRY,
ROUND(CAST (TOTAL_SALE AS FLOAT) / SUM(TOTAL_SALE) OVER(PARTITION BY country) * 100,2)
AS CONTRIBUTION
FROM JOIN_TABLE 
ORDER BY 1,5 DESC ;

-- WHICH PRODUCT CATEGORY CONTRIBUTE THE MOST TO THE OVERALL SALES

SELECT
	category,
	total,
	SUM(total) OVER(),
	CONCAT(ROUND(CAST(total AS FLOAT) / SUM(total) OVER() * 100,2),'%') Percentage 
FROM(
	SELECT 
		category,
		SUM(sales_amount) total
	FROM [gold.fact_sales] s
	RIGHT JOIN [gold.report_products] p
		ON S.product_key = p.product_key
	GROUP BY p.category) T
ORDER BY total DESC ;
/* 
	BIKES CONTRIBUTES BY FAR (96.46%) TO THE OVERALL REVENUE OF THE COMPANY. 
	ACCESSORIES AND CLOTHING ACCOUNTED FOR 2.39 % AND 1.16%, RESPECTIVELY. 
	OVER ALL THE BUSNIESS IS OVER RELYING ON BIKES. 
*/


/*
 ***********************************************************
 DATA SEGMENTATION : CUSTOMER COST-PRODUCT SEGMENTATION
 ***********************************************************
*/

-- SEGMENTE PRODUCT INTO COST RANGES AND COUNT HOW MANY PRODUCTS FALL INTO EACH SEGMENT

WITH Product_Segment AS
(
SELECT 
	product_key,
	product_name,
	-- MIN(cost) IS 1
	-- AVG(cost) IS 661
	-- MAX(cost) IS 2171
	-- THE SEGMENTATION OF PRODUCT INTO THREE COST RANGE  
	cost,
	CASE 
		WHEN cost < 500 THEN ' BELOW RANGE'
		WHEN cost BETWEEN 501 AND 1000 THEN 'MEDIUM RANGE'
		WHEN cost >= 101 THEN 'TOP RANGE'
	END Customer_Range
FROM [gold.report_products]
)
SELECT 
	Customer_Range,
	COUNT(product_key) Total_Product
FROM Product_Segment
GROUP BY Customer_Range ;
/* 
	THE RESULT OF PRODUCT SEGMENTATION BY COST REVELED THAT MOST (82) OF THE PRODUCT 
	FALLS INTO BELOW RANGE WHILE SOME (39) FALLS INTO TOP RANGE AND A VERY FEW (9) 
	FALLS INTO MEDIUM RANGE. WHICH MEANS THE PRODUCT DO NOT COST A LOT OF MONEY  
*/


/*
 ***********************************************************
 DATA SEGMENTATION : CUSTOMER SPEMDING SEGMENTATION
 ***********************************************************
*/

-- VIP : AT LEAST 12 MONTHS OF HISTORY AND SPENDING MORE THAN 5000
-- REGULAR : AT LEAST 12 MONTHS OF HISTORY AND SPENDING LESS THAN 5000
-- NEW CUSTOMER: LESS THAN 12 MONTHS

WITH CTE AS
	(SELECT
		c.customer_key,
		-- COUNT( DISTINCT customer_key) TOTAL NUMBER OF CUSTOMERS 18484
		SUM(s.sales_amount) Total_Spending,
		MIN(s.order_date) First_0rder, 
		MAX(s.order_date) Last_Order,
		DATEDIFF(MONTH, MIN(s.order_date),MAX(s.order_date)) AS Life_Span
	FROM [gold.fact_sales] s
	LEFT JOIN [gold.dim_customers] c
		ON s.customer_key = c.customer_key 
	GROUP BY c.customer_key), 
SEGMENT AS
	(SELECT
		customer_key,
		Total_Spending,
		Life_Span,
		CASE
			WHEN Life_Span >= 12 AND Total_Spending > 5000 THEN 'VIP'
			WHEN Life_Span >= 12 AND Total_Spending < 5000 THEN 'REGULAR'
			WHEN Life_Span < 12 THEN 'NEW'
			ELSE 'NO SEGMENT'
		END CUSTOMERS_SEGMENTS
	FROM CTE )
SELECT 
	CUSTOMERS_SEGMENTS,
	COUNT(DISTINCT customer_key)
FROM SEGMENT 
GROUP BY CUSTOMERS_SEGMENTS 
ORDER BY 2 DESC ;
/* 
	BASED ON THE CUSTOMER SEGMENTATION IT'S FOUND THAT THE LARGEST PORTION OF THE 
	CUSTOMERS (14629) ARE NEW WHILE REGULAR AND VIP CUSTOMER ARE SMALL. THAT MEANS 
	THAT THE COMPANY GAIN  ORE NEW CUSTOMERS THAN IT CAN KEEP. FURTHER RESEARCH SHALL 
	BE CONDUCTED TO SEE HOW MUCH THE COMPANY SPEND TO GAIN A NEW CUSTOMER 
	VERSUS HOW MUCH IT SPENDS TO RETAIN A SINGLE CUSTOMER TOO. 
*/ 


/*
 ***********************************************************
 BULDING A CUSTOMER REPORT 
 ***********************************************************

 REQUIREMENT :
	- BUILD A CUSTOMER REPORT TO CONSOLIDATE KEY CUSTOMER METRICS AND BEHAVIOR.

 * HIGHLIGHT :
	1. COLLECT NAME, AGE AND TRANSACTION DETAILS
	2. SEGMENT CUSTOMERS INTO CATEGORIES (VIP , REGULAR AND NEW) AND AGE GROUP
	3. AGGREGATE CUSTOMERS - LEVEL METRICS
		- TOTAL ORDERS
		- TOTAL SALES 
		- TOTAL PRODUCTS
		- LIFESPAN IN MONTHS
	4. CALCULATE VALUABLE KPIS:
		- RECENCY (MONTH SINCE LAST ORDER)
		- AVERAGE ORDER VALUE
		- AVERAGE MONTHLY SPEND
*/ 

WITH Base_Query AS
	(
	-- base query
	SELECT 
		c.customer_id,s.order_number,s.order_date,
		p.product_name, p.product_segment,
		s.sales_amount, s.quantity, s.price,
		CONCAT(c.first_name,c.last_name) as customer_name, c.country, 
		c.gender,c.birthdate, DATEDIFF(YEAR,c.birthdate,GETDATE()) as age
	FROM [gold.fact_sales] s
	LEFT JOIN [gold.dim_customers] c
		ON s.customer_key = c.customer_key
	LEFT JOIN [gold.report_products] P
		ON s.product_key = p.product_key
	WHERE s.order_date IS NOT NULL 
	),
Aggretion As
	(
	-- aggregation query
	SELECT 
		customer_id,
		customer_name,
		age,
		COUNT(DISTINCT order_number) AS Total_Orders,
		SUM(sales_amount) AS Total_Amount,
		SUM(quantity) AS Quantity_Sold,
		COUNT( DISTINCT product_name) Total_Product,
		-- MAX(order_date) AS Last_purchase,
		DATEDIFF(MONTH, MIN(order_date),MAX(order_date)) Life_Span,
		DATEDIFF(MONTH,MAX(order_date),GETDATE()) AS Recency 
	FROM Base_Query 
	GROUP BY
		customer_id,
		customer_name,
		age
	),
KPI AS 
	(
	SELECT 
		Total_Amount,
		Life_Span,
		Recency,
		age,
		CASE
			WHEN age BETWEEN 18 AND 35 THEN '18-35'
			WHEN age BETWEEN 36 AND 60 THEN '36-60'
			ELSE '+60'
		END age_group,
		CASE
			WHEN Life_Span >= 12 AND Total_Amount > 5000 THEN 'VIP'
			WHEN Life_Span >= 12 AND Total_Amount < 5000 THEN 'REGULAR'
			WHEN Life_Span < 12 THEN 'NEW'
			ELSE 'NO SEGMENT'
		END CUSTOMERS_SEGMENTS
	FROM Aggretion 
	GROUP BY Total_Amount, Life_Span, Recency, age
	)
SELECT 
	*
FROM KPI ; 
