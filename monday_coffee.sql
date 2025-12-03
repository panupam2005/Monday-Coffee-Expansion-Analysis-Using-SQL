SELECT * FROM CITY;
SELECT * FROM CUSTOMERS;
SELECT * FROM PRODUCTS;
SELECT * FROM SALES;

-- Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?
SELECT
	city_name, round(population * 0.25) AS consume_coffee, city_rank
FROM 
	City
ORDER BY
	consume_coffee DESC;


-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
SELECT 
	ci.city_name, 
	SUM(s.total) AS total_revenue 
FROM 
	sales AS s
JOIN 
	customers AS c ON s.customer_id = c.customer_id
JOIN 
	city AS ci ON ci.city_id = c.city_id
WHERE 
	s.sale_date BETWEEN '2023-10-01' AND '2023-12-31'
GROUP BY
	ci.city_name
ORDER BY
	2 DESC;


-- Sales Count for Each Product
-- How many units of each coffee product have been sold?
SELECT 
	p.product_name, count(s.product_id) AS product_sold
FROM 
	sales AS s
JOIN 
	products AS p ON p.product_id = s.product_id
GROUP BY 
	p.product_name
ORDER BY
	2 DESC;


-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?
SELECT 
	ci.city_name, 
	sum(s.total) AS total_sale,
	count(DISTINCT c.customer_id) total_cx,
	ROUND(sum(s.total) / count(DISTINCT c.customer_id)) AS avg_sale_pr_cx
FROM
	sales AS s
JOIN 
	customers AS c ON c.customer_id = s.customer_id
JOIN 
	city AS ci ON ci.city_id = c.city_id
GROUP BY
	city_name
ORDER BY
	2 DESC;


-- City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers.
WITH 
	city_table AS 
	(
	SELECT
		city_name,
		round(((population * 0.25)/1000000),2) AS consume_coffee_in_millions
	FROM 
		city
	),
	customer_table AS
	(
	SELECT 
		ci.city_name,
		count(DISTINCT s.customer_id) AS unique_cx
	FROM 
		sales AS s
	JOIN 
		customers AS c ON c.customer_id = s.customer_id
	JOIN
		city as ci ON ci.city_id = c.city_id
	GROUP BY
		ci.city_id
	)

SELECT 
	city_table.city_name,
	city_table.consume_coffee_in_millions,
	customer_table.unique_cx
FROM 
	city_table
JOIN 
	customer_table ON city_table.city_name = customer_table.city_name
ORDER BY
	3 DESC;


-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
SELECT * 
FROM (
SELECT
	ci.city_name,
	p.product_name,
	count(s.sale_id) AS product_order,
	DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY count(s.sale_id) DESC) AS rank
FROM 
	sales AS s
JOIN 
	products AS p ON s.product_id = p.product_id
JOIN
	customers AS c ON c.customer_id = s.customer_id
JOIN
	city AS ci ON ci.city_id = c.city_id
GROUP BY
	ci.city_name, p.product_name
)
WHERE 
	rank <= 3;

-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?
SELECT 
	ci.city_name,
	count(DISTINCT s.customer_id) AS unique_cx
FROM 
	city AS ci
JOIN 
	customers As c ON c.city_id = ci.city_id
JOIN
	sales AS s ON s.customer_id = c.customer_id
WHERE
	s.product_id IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
GROUP BY
	ci.city_name
ORDER BY
	2 DESC;


-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer
SELECT 
	ci.city_name, 
	sum(s.total) AS total_sale,
	count(DISTINCT c.customer_id) total_cx,
	ROUND(sum(s.total) / count(DISTINCT c.customer_id)) AS avg_sale_pr_cx,
	round(ci.estimated_rent / count(DISTINCT c.customer_id)) rent_pr_cx
FROM
	sales AS s
JOIN 
	customers AS c ON c.customer_id = s.customer_id
JOIN 
	city AS ci ON ci.city_id = c.city_id
GROUP BY
	city_name, estimated_rent
ORDER BY
	2 DESC;


-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).


-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer
WITH my_cte
AS
(
	SELECT 
		ci.city_name, 
		sum(s.total) AS total_sale,
		count(DISTINCT c.customer_id) AS total_cx,
		ROUND(sum(s.total) / count(DISTINCT c.customer_id)) AS avg_sale_pr_cx,
		round(ci.estimated_rent / count(DISTINCT c.customer_id)) AS rent_pr_cx
	FROM
		sales AS s
	JOIN 
		customers AS c ON c.customer_id = s.customer_id
	JOIN 
		city AS ci ON ci.city_id = c.city_id
	GROUP BY
		city_name, estimated_rent
	ORDER BY
		2 DESC	
),
city_table 
AS
(
	SELECT
		city_name, 
		estimated_rent,
		ROUND((population * 0.25)/1000000, 3) as estimated_coffee_consumer_in_millions
	FROM 
		City
)
SELECT
	my_cte.city_name,
	my_cte.total_sale,
	my_cte.total_cx,
	city_table.estimated_coffee_consumer_in_millions,
	city_table.estimated_rent,
	my_cte.avg_sale_pr_cx,
	my_cte.rent_pr_cx
FROM
	my_cte 
JOIN
	city_table ON my_cte.city_name = city_table.city_name
ORDER BY
	2 DESC;