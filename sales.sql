-- Find the top 5 products from each category
-- Using a subquery to filter all ranks under 6
SELECT * FROM(
SELECT category, 
	product_name, 
	ROUND(SUM(sales :: numeric),2) AS product_total_sales, 
	ROUND(SUM(profit :: numeric),2) AS product_total_profit, 
	RANK() OVER(PARTITION BY category ORDER BY SUM(sales :: numeric) DESC) AS product_rank -- Window functions to rank by each category and order by sales casted as numeric
FROM orders
JOIN products USING (product_id)
GROUP BY category, product_name) AS temp
WHERE product_rank < 6

-- Using Common Table Expressions to calculate unit prices

WITH missing AS(
SELECT product_id,
	discount, 
	market,
	region,
	sales,
	quantity
FROM orders
WHERE quantity IS NULL),

unit_prices AS(
	SELECT orders.product_id,
	orders.sales/orders.quantity AS unit_price
FROM orders
WHERE orders.quantity IS NOT NULL AND discount = 0) -- If discount isn't 0 the unit_price column is calculated for each row that has a different discount, creating duplicates in the last query

SELECT DISTINCT missing.*, 
	ROUND((sales::numeric)/unit_price::numeric, 0) AS calculated_quantity 
FROM missing
JOIN unit_prices USING (product_id)
