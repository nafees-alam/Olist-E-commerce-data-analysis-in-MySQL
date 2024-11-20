-- CREATE SCHEMA Olist;   
--here name of database is olist
1. orders:
   order_id (Primary Key)
   customer_id
    order_date
    order_amount
     payment_method
    product_category

2. customers:
   customer_id (Primary Key)
    customer_name
    customer_city
    customer_state

-- USE Olist;
============================================================================================================================================================
-- DATA PREPRATION
-- 1. Check for Missing Data:
   SELECT * 
   FROM orders 
   WHERE order_id IS NULL OR customer_id IS NULL OR order_amount IS NULL;

---The query retrieves all records from the orders table where any of the key columns, namely order_id, customer_id, or order_amount, have missing (NULL) values. 
---This helps identify incomplete or invalid entries in the table that may require correction or further investigation.

2.Identify Duplicate Records:
SELECT order_id, COUNT(*) AS duplicate_count
 FROM orders
 GROUP BY order_id
 HAVING duplicate_count > 1;

--The query checks the orders table for duplicate order_id values. It groups the data by order_id, counts how many times each appears, 
-- and shows only those with more than one occurrence. This helps identify duplicate entries in the table.

-- 3.Ensure Data Consistency (e.g., non-negative order amounts):
 SELECT * 
 FROM orders 
 WHERE order_amount < 0;
--This query retrieves all records from the orders table where the order_amount is less than 0. 
--It helps identify invalid or incorrect entries, as order amounts are typically expected to be non-negative.
-====================================================================================================================================================================
--4. Identifying Trends
1. Monthly Revenue Trend:
 SELECT 
 DATE_FORMAT(order_date, '%Y-%m') AS month,
 SUM(order_amount) AS total_revenue
 FROM orders
 GROUP BY month
 ORDER BY month;
--This query calculates the total revenue for each month from the orders table. 	
--It formats the order_date to show only the year and month, groups the data by month, sums up the order_amount for each month, and displays the results in order by month.
============================================================================================================================================================
-- 2. Order Count Trend Over Time:
 SELECT 
 DATE_FORMAT(order_date, '%Y-%m') AS month,
 COUNT(order_id) AS total_orders
 FROM orders
 GROUP BY month
	-- This query calculates the total number of orders placed each month from the orders table.
	-- It formats the order_date to display only the year and month, groups the data by month, and counts the number of order_id entries for each month. 
	 --The result shows the total orders for every month in the dataset.
SELECT 
product_category, 
 COUNT(order_id) AS order_count
 FROM orders
 GROUP BY product_category
 ORDER BY order_count DESC
 LIMIT 5;
--This query finds the top 5 product categories with the highest number of orders.
--It counts the order_id for each product_category, sorts them in descending order of order count, and displays the top 5 results.
================================================================================================================================================================
 3: Customer Behavior Analysis
1. Top Cities by Number of Customers:
 SELECT 
 customer_city, 
 COUNT(DISTINCT customer_id) AS total_customers
 FROM customers
 GROUP BY customer_city
 ORDER BY total_customers DESC
 LIMIT 5;
--This query finds the top 5 cities with the highest number of unique customers. 
--It counts distinct customer_id values for each customer_city, sorts the cities by customer count in descending order, and displays the top 5 results.

2. Repeat Customers Analysis:
 SELECT 
 customer_id, 
 COUNT(order_id) AS order_count
FROM orders
 GROUP BY customer_id
 HAVING order_count > 1;
--The query is checking how many times each customer has placed an order and only returns customers who have placed more than one order.
--This can help identify repeat buyers
===================================================================================================================================================
	Exploratory Analysis
Performance Across Product Categories:
 SELECT 
 product_category, 
 SUM(order_amount) AS total_revenue, 
 COUNT(order_id) AS total_orders
 FROM orders
 GROUP BY product_category
 ORDER BY total_revenue DESC;
--This query analyzes the performance of each product category by calculating the total revenue and total orders for each category.
--It groups the data by product_category and sorts the results by revenue in descending order, helping to identify the most profitable categories.

. Payment Method Preference:
 SELECT 
 payment_method, 
 COUNT(order_id) AS usage_count,
 SUM(order_amount) AS total_spent
 FROM orders
 GROUP BY payment_method
 ORDER BY usage_count DESC;
--This query calculates the total revenue and order count for each product category.
--It groups the data by product_category and sorts the results by revenue in descending order, 
--showing which categories generate the most income and orders.


3. Revenue by Geolocation:
 SELECT c.customer_state, 
 SUM(o.order_amount) AS total_revenue
 FROM orders o
 JOIN customers c ON o.customer_id = c.customer_id
 GROUP BY c.customer_state
 ORDER BY total_revenue DESC;

--This query calculates the total revenue generated from orders in each state.
--It joins the orders and customers tables using customer_id, groups the data by customer_state, 
--and sorts the states by revenue in descending order.

