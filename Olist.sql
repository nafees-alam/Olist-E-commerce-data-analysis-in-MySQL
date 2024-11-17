CREATE SCHEMA Olist;

USE Olist;

## DATA PREPARATION ------------------------------------------------------------------

# check duplicate by distinct count. Found no duplicate rows in all tables.
SELECT 
   DISTINCT COUNT(*)
FROM  olist_orders oo; 

# update tables
ALTER TABLE olist_products 
ADD COLUMN product_category_name_english VARCHAR(255);

UPDATE  olist_products op
JOIN product_category_name_translation pcnt 
   ON op.product_category_name  = pcnt.product_category_name
SET op.product_category_name_english = pcnt.product_category_name_english; 

/*update empty spaces in 'product_category_name' and NULL values in 'product_category_name_english' 
 *olist_product_dataset has null values of 610 
 */

SELECT 
   *
FROM olist_products op 
WHERE product_category_name ='';

UPDATE 
SET product_category_name = 'N/A'
WHERE product_category_name ='';

UPDATE olist_products 
SET product_category_name_english = 'N/A'
WHERE product_category_name_english IS NULL;

SELECT 
product_category_name,
product_category_name_english
FROM olist_products op 
WHERE product_category_name_english = 'N/A';

#'portateis_cozinha_e_preparadores_de_alimentos' = portable kitchens and food preparers
SELECT 
product_category_name,
product_category_name_english
FROM olist_products op 
WHERE product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos'

UPDATE olist_products 
SET product_category_name_english = 'portable kitchens and food preparers'
WHERE product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos';

UPDATE olist_products 
SET product_category_name_english = 'pc_gamer'
WHERE  product_category_name = 'pc_gamer'

## DATA Analysis ------------------------------------------------------------------
/* 1. What is the total revenue generated by Olist, and how has it changed over time?
 * 2. How many orders were placed on Olist, and how does this vary by month or season?
 * 3. What are the most popular product categories on Olist, and how do their sales volumes compare to each other?
 * 4. What is the average order value (AOV) on Olist, and how does this vary by product category or payment method?
 * 5. How many sellers are active on Olist, and how does this number change over time?
 * 6. What is the distribution of seller ratings on Olist, and how does this impact sales performance?
 * 7. How many customers have made repeat purchases on Olist, and what percentage of total sales do they account for?
 * 8. What is the average customer rating for products sold on Olist, and how does this impact sales performance?
 * 9. What is the average order cancellation rate on Olist, and how does this impact seller performance?
 * 10. What are the top-selling products on Olist, and how have their sales trends changed over time?
 * 11. Which payment methods are most commonly used by Olist customers, and how does this vary by product category or geographic region?
 * 12. How do customer reviews and ratings affect sales and product performance on Olist?
 * 13. Which product categories have the highest profit margins on Olist, and how can the company increase profitability across different categories?
 * 14. Geolocation has high customer density. Calculate customer retention rate according to geolocations.
 */

### 1. a)What is the total revenue generated by Olist? b.)how has it changed over time?-------------------------------------------------------------

# time frame : 2016-09-04 to 2018-10-17
SELECT 
   MIN(order_purchase_timestamp) AS started_date,
   MAX(order_purchase_timestamp) AS ended_Date
FROM olist_orders oo;

# 8 types of order_status: 
SELECT
   order_status,
   COUNT(*) AS invalid_orders
FROM
   olist_orders oo
WHERE
   order_delivered_customer_date IS NULL
GROUP BY
   order_status;

## In order_status: canceled, 6 rows have order_delieved_customer_date ($749) and 619 rows are NULL ($142,507).

SELECT 
   order_status,
   order_delivered_customer_date
FROM olist_orders oo  
WHERE 
     order_status = 'canceled'; 

SELECT 
   oo.order_status,
   ROUND(SUM(opa.payment_value), 0) AS payment 
FROM olist_orders oo 
JOIN 
     olist_payments opa ON oo.order_id = opa.order_id 
WHERE 
     oo.order_status = 'canceled' AND oo.order_delivered_customer_date IS NULL
GROUP BY oo.order_status; 

         
# Total revenue: $15,421,083
SELECT 
   ROUND(SUM(opa.payment_value), 0) total_revenue 
FROM olist_orders oo
JOIN 
     olist_payments opa ON oo.order_id = opa.order_id 
WHERE 
     oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL;
    
    
# canceled value: 143,246
SELECT
  ROUND(SUM(payment_value), 0) AS total_revenue,
  ROUND(SUM(CASE WHEN oo.order_status = 'canceled' THEN NULL 
            ELSE payment_value 
            END)) AS real_revenue,
  ROUND(SUM(payment_value) - (SUM(CASE WHEN oo.order_status = 'canceled' THEN NULL 
            ELSE payment_value 
            END)), 0) AS difference
FROM olist_orders oo
JOIN 
     olist_payments opa ON oo.order_id = opa.order_id;  
    
# numbers of canceled orders: 625
SELECT 
  COUNT(*)
FROM olist_orders oo 
WHERE order_status = 'canceled';


# Yearly sales
SELECT 
   YEAR(oo.order_purchase_timestamp) AS the_year,
   ROUND(SUM(opa.payment_value), 0) AS revenue
FROM 
   olist_orders oo 
JOIN 
   olist_payments opa ON oo.order_id = opa.order_id 
WHERE 
   oo.order_status <> 'canceled'
   AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY the_year
ORDER BY the_year;

# Quarterly sales
SELECT 
   YEAR(oo.order_purchase_timestamp) AS the_year,
   QUARTER(oo.order_purchase_timestamp) AS the_quarter,
   ROUND(SUM(opa.payment_value), 0) AS revenue
FROM 
    olist_orders oo 
JOIN 
    olist_payments opa ON oo.order_id = opa.order_id 
WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY 
    the_year, the_quarter
ORDER BY 
    the_year, the_quarter;
   
# monthly sales
SELECT 
   YEAR(oo.order_purchase_timestamp) AS the_year,
   QUARTER(oo.order_purchase_timestamp) AS the_quarter,
   MONTH(oo.order_purchase_timestamp) AS the_month,
   ROUND(SUM(opa.payment_value), 0) AS revenue
FROM 
    olist_orders oo 
JOIN 
    olist_payments opa ON oo.order_id = opa.order_id 
WHERE 
     oo.order_status <> 'canceled'
     AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY 
    the_year, the_quarter, the_month
ORDER BY 
    the_year, the_quarter, the_month DESC;
   
 
 ##   2018-10- all cancelled (4 rows) 
   
   SELECT *
   FROM olist_orders oo 
   WHERE order_purchase_timestamp LIKE '2018-10_%%'
   

### 2. How many orders were placed on Olist, and how does this vary by month or season? 96,470-------------------------------------------------- 

# total orders: 96,470
SELECT
   order_id
FROM
   olist_orders oo
WHERE
   order_status <> 'canceled'
   AND order_delivered_customer_date IS NOT NULL;
   
# Quarterly orders
SELECT
   YEAR(order_purchase_timestamp) AS the_year,
   QUARTER(order_purchase_timestamp) AS the_quarter,
   COUNT(*) AS num_order
FROM
   olist_orders oo
WHERE
   order_status <> 'canceled'
   AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY
   the_year, the_quarter
ORDER BY
   the_year, the_quarter;

# monthly orders
SELECT
   YEAR(order_purchase_timestamp) AS the_year,
   MONTH(order_purchase_timestamp) AS the_month,
   COUNT(*) AS num_order
FROM
   olist_orders oo
WHERE
   order_status <> 'canceled'
   AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY
   the_year, the_month
ORDER BY
   num_order DESC;

### 3. What are the most popular product categories on Olist, and how do their sales volumes compare to each other?-----------------------------

## total product_id count:110,189
 SELECT
    COUNT(oi.product_id) AS total_product_id
FROM
    olist_items oi
JOIN 
    olist_orders oo ON oi.order_id = oo.order_id
WHERE
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL

# most popular product categories
SELECT 
   op.product_category_name_english AS product_name,
   COUNT(oo.order_id) AS num_orders,
   ROUND(100.0 * (COUNT(oo.order_id) / total_orders.total_num_orders), 2) AS percentage
FROM 
    olist_orders oo
JOIN 
    olist_items oi ON oo.order_id = oi.order_id 
JOIN
    (SELECT
        product_id,
        product_category_name_english
     FROM 
        olist_products op) AS op ON oi.product_id = op.product_id
CROSS JOIN 
    (
      SELECT COUNT(oo.order_id) AS total_num_orders
      FROM olist_orders oo 
      JOIN 
          olist_items oi ON oo.order_id = oi.order_id 
      JOIN 
          olist_products op ON oi.product_id = op.product_id 
      WHERE  
          oo.order_status <> 'canceled'
          AND oo.order_delivered_customer_date IS NOT NULL -- 110,189rows
    ) AS total_orders
WHERE
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY
    product_name, total_num_orders
ORDER BY 
    percentage DESC;
   
### 4. What is the average order value (AOV) on Olist, and how does this vary by product category or payment method?----------------------------
 
# AOV of product categories 

/*total sales: 15,421,083, total orders:96,469 
 * (order_id 'bfbd0f9bdef84302105ad712db648a6c'does not have payment value)
 * total costs: 15,418,395, total orders:96,470 
 */ 
 
SELECT 
   ROUND(SUM(opa.payment_value) / COUNT(oo.order_id), 0) AS AOV,
   ROUND(SUM(oi.cost) / COUNT(oo.order_id), 0) AS CPO,	
   ROUND(SUM(opa.payment_value) / COUNT(oo.order_id) -  
   (SUM(cost) / COUNT(oo.order_id)), 0) AS profit_per_order
FROM
   olist_orders oo
JOIN 
    (SELECT 
        oo.order_id AS order_id,
        SUM(payment_value) AS payment_value
     FROM 
     	olist_payments opa 
     JOIN 
     	olist_orders oo ON oo.order_id = opa.order_id
     WHERE
	oo.order_status <> 'canceled'
	AND oo.order_delivered_customer_date IS NOT NULL
     GROUP BY order_id) AS opa ON oo.order_id = opa.order_id -- 96,469 rows($15421083)
JOIN
    (SELECT 
        oo.order_id AS order_id,
        SUM(price + freight_value) AS cost
     FROM
     	olist_items oi 
     JOIN 
     	olist_orders oo ON oo.order_id = oi.order_id
     WHERE
	oo.order_status <> 'canceled'
	AND oo.order_delivered_customer_date IS NOT NULL
     GROUP BY order_id) AS oi ON oo.order_id =  oi.order_id -- 96,470 rows($15418395)  
   
   
   
## profit_per_order:233 rows
SELECT 
   oo.order_id AS order_id,
   ROUND(SUM(opa.payment_value) / COUNT(oo.order_id), 0) AS AOV,
   ROUND(SUM(oi.cost) / COUNT(oo.order_id), 0) AS CPO,	
   ROUND(SUM(opa.payment_value) / COUNT(oo.order_id) -  
   (SUM(cost) / COUNT(oo.order_id)), 0) AS profit_per_order
FROM
   olist_orders oo
JOIN 
    (SELECT 
        oo.order_id AS order_id,
        SUM(payment_value) AS payment_value
     FROM 
     	olist_payments opa 
     JOIN 
     	olist_orders oo ON oo.order_id = opa.order_id
     WHERE
	oo.order_status <> 'canceled'
	AND oo.order_delivered_customer_date IS NOT NULL
     GROUP BY order_id) AS opa ON oo.order_id = opa.order_id -- 96,469 rows($15421083)
JOIN
    (SELECT 
        oo.order_id AS order_id,
        SUM(price + freight_value) AS cost
     FROM
     	olist_items oi 
     JOIN 
     	olist_orders oo ON oo.order_id = oi.order_id
     WHERE
	oo.order_status <> 'canceled'
	AND oo.order_delivered_customer_date IS NOT NULL
     GROUP BY order_id) AS oi ON oo.order_id =  oi.order_id -- 96,470 rows($15418395)        
GROUP BY 
   order_id
HAVING 
   profit_per_order > 0
ORDER BY 
   profit_per_order DESC;

# AOV on product category(COUONT DISCINCT order_id = 233 rows ):260 counts
SELECT
   op.product_category_name_english AS product_name,
   COUNT(profit.order_id) AS profit_count
   -- COUNT(DISTINCT oi.order_id)
FROM
   olist_items oi
JOIN
    olist_products op ON oi.product_id = op.product_id 
JOIN (
	SELECT 
	   oo.order_id AS order_id,
	   ROUND(SUM(opa.payment_value) / COUNT(oo.order_id), 0) AS AOV,
	   ROUND(SUM(oi.cost) / COUNT(oo.order_id), 0) AS CPO,	
	   ROUND(SUM(opa.payment_value) / COUNT(oo.order_id) -  
	   (SUM(cost) / COUNT(oo.order_id)), 0) AS profit_per_order
	FROM
	   olist_orders oo
	JOIN 
	    (SELECT 
	        oo.order_id AS order_id,
	        SUM(payment_value) AS payment_value
	     FROM 
	     	olist_payments opa 
	     JOIN 
	     	olist_orders oo ON oo.order_id = opa.order_id
	     WHERE
		oo.order_status <> 'canceled'
		AND oo.order_delivered_customer_date IS NOT NULL
	     GROUP BY order_id) AS opa ON oo.order_id = opa.order_id -- 96,469 rows($15421083)
	JOIN
	    (SELECT 
	        oo.order_id AS order_id,
	        SUM(price + freight_value) AS cost
	     FROM
	     	olist_items oi 
	     JOIN 
	     	olist_orders oo ON oo.order_id = oi.order_id
	     WHERE
		oo.order_status <> 'canceled'
		AND oo.order_delivered_customer_date IS NOT NULL
	     GROUP BY order_id) AS oi ON oo.order_id =  oi.order_id -- 96,470 rows($15418395)        
	GROUP BY 
	   order_id
	HAVING 
	   profit_per_order > 0
	ORDER BY 
	   profit_per_order DESC) AS profit ON profit.order_id = oi.order_id 
GROUP BY 
   product_name
ORDER BY 
   profit_count DESC;

# AOV of payment methods: 
# total payment value: 15,432,083
	
SELECT 
    payment_type,
    ROUND(SUM(opa.payment_value)/ COUNT(DISTINCT oo.order_id), 0) AS AOV
FROM
    olist_orders oo
JOIN 
    olist_payments opa ON oo.order_id = opa.order_id
WHERE
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY
    payment_type 
ORDER BY
    AOV DESC;


### 5. How many sellers are active on Olist, and how does this number change over time?---------------------------------------------------------

# 3095 distict seller_id
SELECT 
COUNT(DISTINCT seller_id)
FROM olist_sellers os;

## Checking order_id with multiple seller_id
SELECT 		   
   order_id,
   COUNT(order_item_id),
   COUNT(DISTINCT seller_id) 
FROM olist_items oi 
GROUP BY order_id
HAVING COUNT(DISTINCT seller_id) > 1;

## There are 1,786 active sellers.
SET sql_mode = '';
SELECT
   COUNT(seller_id) AS num_active_sellers
FROM (
      SELECT
         seller_id,
	 DATEDIFF(MAX(order_purchase_timestamp), MAX(previous_order_date)) AS days_between_orders
      FROM(
           SELECT
               oi.seller_id, 
	       oo.order_id,
	       oo.order_purchase_timestamp,
	       LAG(oo.order_purchase_timestamp, 1) 
	           OVER (PARTITION BY oi.seller_id ORDER BY oo.order_purchase_timestamp) AS previous_order_date
	    FROM
	       Olist_orders oo
	    JOIN 
	       (SELECT 
		    si.seller_id AS seller_id,
		    oi.order_id,
		    COUNT(oi.order_item_id) AS order_item_count
		FROM 
		     olist_items oi
		JOIN 
		   (SELECT 
		        order_id,
		        COUNT(DISTINCT seller_id) AS distinct_seller_count
		    FROM 
		        olist_items
		    GROUP BY 
			order_id
-- 		    HAVING 
-- 		    COUNT(DISTINCT seller_id) > 1
		    ) AS subquery ON oi.order_id = subquery.order_id
	      JOIN 
		 (SELECT 
		      order_id,
		      seller_id
		  FROM 
		      olist_items
		  GROUP BY 
		      order_id, seller_id) AS si ON oi.order_id = si.order_id
	       GROUP BY 
		   oi.order_id, si.seller_id
	       ORDER BY 
		   si.seller_id,oi.order_id) AS oi ON oi.order_id = oo.order_id	
	       WHERE
		   oo.order_status <> 'canceled'
		   AND oo.order_delivered_customer_date IS NOT NULL
	       ORDER BY
		    oi.seller_id, oo.order_purchase_timestamp DESC				
	      ) AS second_last_order_date
	GROUP BY
		seller_id
	HAVING
		DATEDIFF(MAX(order_purchase_timestamp), MAX(previous_order_date)) <= 30
		AND DATEDIFF(MAX(order_purchase_timestamp), MAX(previous_order_date)) IS NOT NULL
	ORDER BY
		DATEDIFF(MAX(order_purchase_timestamp), MAX(previous_order_date))
) AS active_seller;

## how do active sellers orders change over time?

# actvive sellers changed over time (total count:1786)

SELECT
   YEAR(order_purchase_timestamp) AS the_year,
   QUARTER(order_purchase_timestamp) AS the_quarter,
   MONTH(order_purchase_timestamp) AS the_month,
   COUNT(seller_id) AS active_seller_order_count
FROM
   (
    SELECT
	seller_id,
	MAX(order_purchase_timestamp) AS order_purchase_timestamp
    FROM(
         SELECT
             oi.seller_id, 
	     oo.order_id,
	     oo.order_purchase_timestamp,
	     LAG(oo.order_purchase_timestamp, 1) 
	           OVER (PARTITION BY oi.seller_id ORDER BY oo.order_purchase_timestamp) AS previous_order_date
	  FROM
	     Olist_orders oo
	  JOIN 
	       (SELECT 
		    si.seller_id AS seller_id,
		    oi.order_id,
		    COUNT(oi.order_item_id) AS order_item_count
		FROM 
		    olist_items oi
	   JOIN 
		(SELECT 
		     order_id,
		     COUNT(DISTINCT seller_id) AS distinct_seller_count
		 FROM 
		     olist_items
		 GROUP BY 
		     order_id
-- 		 HAVING 
-- 		 COUNT(DISTINCT seller_id) > 1
		 ) AS subquery ON oi.order_id = subquery.order_id
	   JOIN 
		(SELECT 
		     order_id,
		     seller_id
		 FROM 
		     olist_items
		 GROUP BY 
		     order_id, seller_id) AS si ON oi.order_id = si.order_id
	    GROUP BY 
		oi.order_id, si.seller_id
	    ORDER BY 
		si.seller_id,oi.order_id) AS oi ON oi.order_id = oo.order_id	
	    WHERE
		oo.order_status <> 'canceled'
		AND oo.order_delivered_customer_date IS NOT NULL
	    ORDER BY
		oi.seller_id,
		oo.order_purchase_timestamp DESC				
	      ) AS second_last_order_date
	GROUP BY
	    seller_id
	HAVING
	    DATEDIFF(MAX(order_purchase_timestamp), MAX(previous_order_date)) <= 30
	    AND DATEDIFF(MAX(order_purchase_timestamp), MAX(previous_order_date)) IS NOT NULL
	) AS sub
GROUP BY
	the_year, the_quarter, the_month
ORDER BY
	the_year, the_quarter, the_month;



### 6. What is the distribution of seller ratings on Olist, and how does this impact sales performance?------------------------------------------

# 555 order_id have more than 1 review
SELECT 
   order_id,
   COUNT(order_id)
FROM olist_reviews ore
GROUP BY order_id 
HAVING COUNT(order_id) > 1

SELECT
   review_score,
   COUNT(*) AS num_review,
   ROUND((100.0 * COUNT(*)/ tot_re.total_re),2) AS percentage
FROM
   olist_reviews ore
CROSS JOIN ( 
	SELECT
	  COUNT(*) AS total_re
	FROM
	  olist_items oi) AS tot_re
GROUP BY
   review_score, total_re
ORDER BY
   review_score DESC; -- 100,000 rows

## create view 
CREATE OR REPLACE VIEW review AS
SELECT 
   oo.order_id AS order_id,
   ROUND(AVG(review_score), 0) AS review_score
FROM
   olist_orders oo
JOIN 
   olist_reviews ore ON oo.order_id = ore.order_id
WHERE
   oo.order_status <> 'canceled'
   AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY
   oo.order_id; -- 96,470 rows

CREATE VIEW OR REPLACE payment AS
SELECT
   oo.order_id AS order_id,
   SUM(op.payment_value) AS payment_value
FROM
   olist_orders oo
JOIN 
   olist_payments op ON
   oo.order_id = op.order_id
WHERE
    oo.order_status <> 'canceled'
   AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY
   oo.order_id; -- 96,469 rows

SELECT 
    r.review_score,
    COALESCE(ROUND(SUM(p.payment_value), 0), 0) AS total_payment_value,   
    ROUND(100.0 * (COALESCE(ROUND(SUM(p.payment_value), 0), 0)/ all_sum.all_pay),2) AS percentage
FROM 
    review r
JOIN 
    payment p ON r.order_id = p.order_id
CROSS JOIN(
     SELECT COALESCE(ROUND(SUM(p.payment_value), 0), 0) AS all_pay
     FROM payment p) AS all_sum
GROUP BY 
    r.review_score, all_pay
ORDER BY 
    r.review_score DESC;

## 7. How many customers have made repeat purchases on Olist, and what percentage of total sales do they account for?-------------------------

 #  distinct customers: 96,096
SELECT 
   COUNT(DISTINCT customer_unique_id) AS customers
FROM olist_customers oc; 
	
## 2,801 return cusomers
   
SELECT
   COUNT(*) AS num_return_customer
FROM
  (
    SELECT 
	oc.customer_unique_id AS re_customer,
	COUNT(DISTINCT oo.order_id) AS num_re_customers
    FROM
	olist_orders oo
    JOIN 
        olist_customers oc ON oo.customer_id = oc.customer_id
    WHERE
	oo.order_status <> 'canceled'
	AND oo.order_delivered_customer_date IS NOT NULL 
    GROUP BY
	re_customer
    HAVING
	COUNT(oo.order_id) >1
    ORDER BY
	num_re_customers DESC) AS return_customers;

# revenue of return customers: 864,357
	
SELECT
   ROUND(SUM(total_rev), 0) AS revenue_re_customers
FROM
   (
    SELECT 
	oc.customer_unique_id AS re_customer,
	COUNT(DISTINCT oo.order_id) AS num_re_customers,
	SUM(opa.payment_value) AS total_rev
    FROM
	olist_orders oo
    JOIN 
        olist_customers oc ON oo.customer_id = oc.customer_id
    JOIN 
        olist_payments opa ON oo.order_id = opa.order_id
    WHERE
	oc.customer_unique_id IN 
       (
	SELECT
	   oc.customer_unique_id
	FROM
	   olist_orders oo
	JOIN 
	   olist_customers oc ON oo.customer_id = oc.customer_id
	WHERE 
	   oo.order_status <> 'canceled'
	   AND oo.order_delivered_customer_date IS NOT NULL 
	GROUP BY
	   oc.customer_unique_id
	HAVING
	   COUNT(oo.order_id) > 1 -- 2801rows
	 )                        
	AND oo.order_status <> 'canceled'
	AND oo.order_delivered_customer_date IS NOT NULL
     GROUP BY
	re_customer
     HAVING
	COUNT(oo.order_id) <>1
     ORDER BY
	num_re_customers) AS sub -- 2801rows;
			

## 5.61 % of total_revenue are from return customers

SELECT
    ROUND(100.0 * return_rev / total_revenue, 2) AS percentage_of_return_customer
FROM
   (SELECT
	ROUND(SUM(total_rev), 0) AS return_rev
    FROM
	(SELECT 
	    oc.customer_unique_id AS re_customer,
	    COUNT(DISTINCT oo.order_id) AS num_re_customers,
	    SUM(opa.payment_value) AS total_rev
	 FROM
	    olist_orders oo
	 JOIN 
            olist_customers oc ON oo.customer_id = oc.customer_id
	 JOIN 
            olist_payments opa ON oo.order_id = opa.order_id
	 WHERE
	    oc.customer_unique_id IN 
	   (
	    SELECT
		oc.customer_unique_id
	    FROM
		olist_orders oo
	    JOIN 
	        olist_customers oc ON oo.customer_id = oc.customer_id
	     WHERE 
		oo.order_status <> 'canceled'
		AND oo.order_delivered_customer_date IS NOT NULL 
	     GROUP BY
		oc.customer_unique_id
	     HAVING
	 	COUNT(oo.order_id) > 1 -- 2801rows
		  )                        
		AND oo.order_status <> 'canceled'
		AND oo.order_delivered_customer_date IS NOT NULL
	GROUP BY
	   re_customer
	HAVING COUNT
	   (oo.order_id) <>1
	ORDER BY
	   num_re_customers) AS sub) AS return_customers_revenue, -- 864,357
	(
	SELECT
	   ROUND(SUM(opa.payment_value), 0) AS total_revenue
	FROM
	   olist_orders oo
	JOIN 
           olist_payments opa ON oo.order_id = opa.order_id
	WHERE
	   oo.order_status <> 'canceled'
	   AND oo.order_delivered_customer_date IS NOT NULL) AS total_revenue; -- 15,421,083
	   	   
### 8. What is the average customer rating for products sold on Olist, and how does this impact sales performance?----------------------------       

#average review score:4.1
	
SELECT
   ROUND(AVG(ore.review_score), 1) AS avg_review
FROM
   olist_orders oo
JOIN 
   olist_reviews ore ON oo.order_id = ore.order_id
WHERE
   order_status <> 'canceled'
   AND order_delivered_customer_date IS NOT NULL;

# order_id review:96,470 rows
SELECT 
   oo.order_id AS order_id,
   AVG(ore.review_score)
FROM 
   olist_reviews ore
JOIN 
   olist_orders oo ON oo.order_id = ore.order_id 
WHERE
   order_status <> 'canceled'
   AND order_delivered_customer_date IS NOT NULL
GROUP BY 
    order_id;

# product performance in review scores: num_order:110,189

SELECT 
   product_name,
   ROUND(AVG(ore.review_score), 1) AS avg_review_score,
   COUNT(oo.order_id) AS num_order,
   RANK() OVER (ORDER BY COUNT(oo.order_id) DESC) AS rnk
FROM
   olist_orders oo 
JOIN 
   (SELECT 
	oi.order_id AS order_id,
	oi.product_id AS product_id, 
	op.product_category_name_english AS product_name
    FROM 
	olist_items oi
    JOIN 
	olist_orders oo ON
	oo.order_id = oi.order_id
    JOIN 
	olist_products op ON
	oi.product_id = op.product_id
    WHERE 
	oo.order_status <> 'canceled'
	AND oo.order_delivered_customer_date IS NOT NULL
    ORDER BY
	op.product_category_name_english DESC) AS oi ON oi.order_id = oo.order_id -- 110,189 rows
 JOIN 
   (SELECT 
	oo.order_id AS order_id,
	AVG(ore.review_score) AS review_score
    FROM 
	olist_reviews ore
    JOIN 
	olist_orders oo ON oo.order_id = ore.order_id 
    WHERE
	order_status <> 'canceled'
	AND order_delivered_customer_date IS NOT NULL
     GROUP BY order_id) AS ore ON oo.order_id = ore.order_id -- 96,470 rows
WHERE
   oo.order_status <> 'canceled'
   AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY
   product_name
ORDER BY
   rnk;

## ---------- NPS(Net Promoter score) ------------- ##
/* customer experience metric
 */ 
SELECT
   SUM(CASE WHEN review_score IN (5,4) THEN 1 ELSE 0 END) AS positive_count,
   SUM(CASE WHEN review_score =1 THEN 1 ELSE 0 END) AS negative_count,
   COUNT(*) AS total_count,
   100.0*(SUM(CASE WHEN review_score IN (5,4) THEN 1 ELSE 0 END) -
	 SUM(CASE WHEN review_score =1 THEN 1 ELSE 0 END))/COUNT(*)  AS NPS
FROM 
olist_reviews or2

### 9. What is the average order cancellation rate on Olist, and how does this impact seller performance?-------------------------------------

# canceled rate: 0.63%
	
SELECT
   order_status,
   COUNT(order_id) AS num_order,
   ROUND(100 * COUNT(order_id) / SUM(COUNT(order_id)) OVER (), 2) AS percentage
FROM
   olist_orders oo
GROUP BY
   order_status;

### 10. What are the top-selling products on Olist, and how have their sales trends changed over time?----------------------------------------

## top 3 selling products (same query as Q3)
SELECT 
    op.product_category_name_english AS product_name,
    COUNT(oo.order_id) AS num_order
FROM
    olist_orders oo
JOIN 
    olist_items oi ON oo.order_id = oi.order_id 
JOIN
    (SELECT
        product_id,
        product_category_name_english
     FROM 
        olist_products op) AS op ON oi.product_id = op.product_id
WHERE
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY
    product_name
ORDER BY 
    num_order DESC; -- 110,189 rows
   
## how have their sales trends changed over time? 

SELECT 
    YEAR(oo.order_purchase_timestamp) AS the_year,
    op.product_category_name_english AS product_name,
    COUNT(oo.order_id) AS num_order,
    RANK() OVER(ORDER BY COUNT(oo.order_id) DESC) AS rnk
FROM
    olist_orders oo
JOIN 
    olist_items oi ON oo.order_id = oi.order_id 
JOIN
    (SELECT
        product_id,
        product_category_name_english
     FROM 
        olist_products op) AS op ON oi.product_id = op.product_id
WHERE
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY
    product_name, the_year
ORDER BY 
    the_year; -- 110,189 rows

/* 11. Which payment methods are most commonly used by Olist customers, ----------------------------------------------------------------------
 * and how does this vary by product category or geographic region?
 */
  
# credit card is the most commonly used method. 
SELECT
    payment_type,
    COUNT(*) AS num_pay_type
FROM
    olist_payments opa
JOIN 
    olist_orders oo ON oo.order_id = opa.order_id
WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY
    payment_type; -- 100,748 rows

## payment types by products (total num_order count: 112,628)
SELECT 
   product_name,
   payment_type,
   COUNT(*) AS num_order,
   RANK() OVER (ORDER BY COUNT(*) DESC) AS num_order_rnk
FROM
   olist_orders oo
JOIN (
    SELECT 
	oi.order_id AS order_id,
	oi.product_id AS product_id, 
	op.product_category_name_english AS product_name 
    FROM 
	olist_items oi 
    JOIN 
	olist_orders oo ON oo.order_id = oi.order_id 
    JOIN 
	olist_products op ON oi.product_id = op.product_id 
    WHERE 
	oo.order_status <> 'canceled'
	AND oo.order_delivered_customer_date IS NOT NULL
    ORDER BY
	    op.product_category_name_english DESC) AS oi ON oi.order_id = oo.order_id -- 110,189 rows
 JOIN (
     SELECT
	  oo.order_id AS order_id,
	  opa.payment_type AS payment_type,
	  SUM(opa.payment_value) AS payment_value
     FROM
	  olist_payments opa
     JOIN 
	  olist_orders oo ON oo.order_id = opa.order_id
     WHERE
	  oo.order_status <> 'canceled'
	  AND oo.order_delivered_customer_date IS NOT NULL
     GROUP BY
	   oo.order_id, opa.payment_type) AS opa ON oo.order_id = opa.order_id -- 98,651 rows
  WHERE 
     oo.order_status <> 'canceled'
     AND oo.order_delivered_customer_date IS NOT NULL
  GROUP BY
     product_name, payment_type
  ORDER BY
     product_name DESC,num_order DESC;

# payment group by order_id : 98,651 rows
SELECT
    DISTINCT oo.order_id,
    opa.payment_type
FROM
    olist_payments opa
JOIN 
    olist_orders oo ON oo.order_id = opa.order_id
WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL

# rows of product_id: 110,189 rows
SELECT 
    oi.order_id AS order_id,
    oi.product_id AS product_id, 
    op.product_category_name_english AS product_name
FROM 
    olist_items oi
JOIN 
    olist_orders oo ON oo.order_id = oi.order_id
JOIN 
    olist_products op ON oi.product_id = op.product_id
WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
ORDER BY
    op.product_category_name_english DESC;

    
## payment types by geographic region: 98,651rows
SELECT
    oc.customer_city AS city,
    payment_type,
    COUNT(DISTINCT opa.order_id) AS order_num,
    RANK() OVER (ORDER BY COUNT(DISTINCT opa.order_id) DESC) AS rnk
FROM
    olist_payments opa
JOIN 
    olist_orders oo ON opa.order_id = oo.order_id
JOIN 
    olist_customers oc ON oo.customer_id = oc.customer_id
WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY
    payment_type, city
ORDER BY
    order_num DESC;

###  12. How do customer reviews and ratings affect sales and product performance on Olist?-----------------------------------------------------

# oo.order_id ='bfbd0f9bdef84302105ad712db648a6c' didn't have payment value, cost:143.46
SELECT
    AVG(review_score) AS avg_reveiw,
    ROUND(SUM(profit), 0) AS profit
FROM (
     SELECT 
	oo.order_id,
	review_score,
	payment_value,
	cost,
	(payment_value - cost) AS profit
     FROM
	olist_orders oo
     JOIN (
	SELECT
	    oo.order_id AS order_id,
	    ROUND(AVG(review_score), 2) AS review_score
	FROM
	    olist_reviews ore
	JOIN 
	    olist_orders oo ON oo.order_id = ore.order_id 
	WHERE 	
	    oo.order_status <> 'canceled'
	    AND oo.order_delivered_customer_date IS NOT NULL
	GROUP BY
	    oo.order_id) AS ore ON oo.order_id = ore.order_id -- 96,470 rows
	JOIN(
	   SELECT
	      oo.order_id AS order_id,
	      SUM(payment_value) AS payment_value
	   FROM
	      olist_payments opa
	   JOIN 
	      olist_orders oo ON oo.order_id = opa.order_id 
	   WHERE 	
	      oo.order_status <> 'canceled'
	      AND oo.order_delivered_customer_date IS NOT NULL
	   GROUP BY
	      oo.order_id) AS opa ON oo.order_id = opa.order_id -- 96,469 rows 15,421,083
	JOIN(
	   SELECT
	      oo.order_id AS order_id,
	      SUM(price + freight_value) AS cost
	   FROM
	      olist_items oi
	   JOIN 
	      olist_orders oo ON oo.order_id = oi.order_id 
	   WHERE 	
	      oo.order_status <> 'canceled'
	      AND oo.order_delivered_customer_date IS NOT NULL
	   GROUP BY
	      oo.order_id) AS oi ON oo.order_id = oi.order_id -- 96,470 rows 15,418,395
    ) AS profit;

/* 13. Which product categories have the highest profit margins on Olist, 
 *      and how can the company increase profitability across different categories?
 */

	SELECT 
	   oo.order_id,
	   review_score,
	   payment_value,
	   cost,
	   ROUND((payment_value - cost), 0) AS profit
	FROM
	   olist_orders oo
	JOIN (
	   SELECT
		oo.order_id AS order_id,
		ROUND(AVG(review_score), 2) AS review_score
	   FROM
		olist_reviews ore
	   JOIN 
	        olist_orders oo ON oo.order_id = ore.order_id 
	   WHERE 	
		oo.order_status <> 'canceled'
		AND oo.order_delivered_customer_date IS NOT NULL
	   GROUP BY
		oo.order_id) AS ore ON oo.order_id = ore.order_id -- 96,470 rows
	JOIN(
	   SELECT
		oo.order_id AS order_id,
		SUM(payment_value) AS payment_value
	   FROM
		olist_payments opa
	   JOIN 
	        olist_orders oo ON oo.order_id = opa.order_id 
	   WHERE 	
		oo.order_status <> 'canceled'
		AND oo.order_delivered_customer_date IS NOT NULL
	   GROUP BY
		oo.order_id) AS opa ON oo.order_id = opa.order_id -- 96,469 rows 15,421,083
	JOIN(
	   SELECT
		oo.order_id AS order_id,
		SUM(price + freight_value) AS cost
	   FROM
		olist_items oi
	   JOIN 
	        olist_orders oo ON oo.order_id = oi.order_id 
	   WHERE 	
	        oo.order_status <> 'canceled'
		AND oo.order_delivered_customer_date IS NOT NULL
           GROUP BY
		oo.order_id) AS oi ON oo.order_id = oi.order_id -- 96,470 rows 15,418,395; -- 233 rows
	WHERE 
	   ROUND((payment_value - cost), 0) > 0
	ORDER BY 
	   ROUND((payment_value - cost), 0) > 0 DESC; -- 233 rows
	     
	

SELECT 
*
FROM olist_items oi 
WHERE oi.order_id = '6e5fe7366a2e1bfbf3257dba0af1267f';

SELECT 
*
FROM olist_products op 
WHERE product_id IN ('7721582bb750762d81850267d19881c1','65bb78cf0bbc3ca6406f30e6793736f9');

    

# 14. Geolocation has high customer density. Calculate customer retention rate according to geolocations.

# customer density in states
	
SELECT 
   oc.customer_state AS state,
   COUNT(oc.customer_unique_id) AS num_customer   
FROM olist_orders oo 
JOIN 
     olist_customers oc ON oo.customer_id = oc.customer_id 
WHERE 
     oo.order_status <> 'canceled'
     AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY state
ORDER BY num_customer DESC;

## CRR top 3 states: AC, RO, RJ

WITH return_customers AS(
SELECT
   oc.customer_state AS state,
   COUNT(oc.customer_unique_id) AS re_customer
FROM
   olist_customers oc
WHERE
   oc.customer_unique_id IN(
    SELECT
	unique_id
    FROM(
	  SELECT
	     oc.customer_unique_id AS unique_id,
	     COUNT(DISTINCT oo.order_id)
	  FROM
	     olist_orders oo
	  JOIN 
             olist_customers oc ON oo.customer_id = oc.customer_id
	  WHERE
	     oo.order_status <> 'canceled'
	     AND oo.order_delivered_customer_date IS NOT NULL
	  GROUP BY
	     oc.customer_unique_id
	   HAVING
	     COUNT(oo.order_id) >1
	   ORDER BY
	     COUNT(DISTINCT oo.order_id) DESC) AS sub)
GROUP BY
   oc.customer_state
),
total_customers AS (
SELECT
   oc.customer_state AS state,
   COUNT(oc.customer_unique_id) AS tot_customer
FROM
   olist_customers oc
JOIN 
   olist_orders oo ON
   oo.customer_id = oc.customer_id
WHERE
   oo.order_status <> 'canceled'
   AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY
   oc.customer_state
)
   
SELECT
   rc.state AS state,
   ROUND(re_customer / tot_customer * 100, 2) AS CRR
FROM
   return_customers rc
JOIN 
   total_customers tc ON rc.state = tc.state
GROUP BY
   state
ORDER BY
   CRR DESC;