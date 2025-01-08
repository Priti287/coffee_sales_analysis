                  #-------CREATE DATABASE SCHEMA------#
                  
CREATE DATABASE monday_coffee_db;
USE monday_coffee_db;

CREATE TABLE city
(
	city_id	INT PRIMARY KEY,
	city_name VARCHAR(15),	
	population	BIGINT,
	estimated_rent	FLOAT,
	city_rank INT
);



CREATE TABLE customers
(
	customer_id INT PRIMARY KEY,	
	customer_name VARCHAR(25),	
	city_id INT,
	CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);


CREATE TABLE products
(
	product_id	INT PRIMARY KEY,
	product_name VARCHAR(35),	
	Price float
);


CREATE TABLE sales
(
	sale_id	INT PRIMARY KEY,
	sale_date	date,
	product_id	INT,
	customer_id	INT,
	total FLOAT,
	rating INT,
	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
);

SELECT * FROM city;
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales;


									## ------EASY QUESTIONS------##
# Question 1: List top 5 products with High price.
SELECT product_name, price
FROM products
ORDER BY price DESC
LIMIT 5;

# Question 2: How many people in each city are estimated to consume coffee.
SELECT 
    city_name, 
    population, 
    ROUND(population * 0.7) AS estimated_coffee_consumers
FROM city;


# Question 3: Which customer has spent the most on purchases?
SELECT c.customer_id, c.customer_name, sum(s.total) AS total_spent
FROM customers AS c
JOIN sales AS s ON c.customer_id = s.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;

#Question 4: Find the total sales amount for each product.
SELECT product_name , sum(s.total) as total_sales
FROM products AS p
JOIN sales AS s ON p.product_id = s.product_id
GROUP BY product_name
ORDER BY total_sales DESC;

# Question 5: Find the average sales per day.
SELECT sale_id, sale_date , AVG(s.total) AS average_sales_per_day
FROM sales AS s
GROUP BY sale_id
ORDER BY  sale_date;

# Question 6: List customers who have given a rating of 5.
SELECT customer_name , rating
FROM customers as c
JOIN sales AS s ON c.customer_id= s.customer_id
WHERE rating = 5;

# Question 7: Find the total revenue generated across all sales.
SELECT sum(total) AS total_revenue
FROM sales;


# Question 8: How many people in each city are estimated to consume coffee, given that 25% of the population does?
    SELECT city_name,
	ROUND(
	(population * 0.25)/1000000, 2) AS coffee_consumers_in_millions,
	city_rank
	FROM city
	ORDER BY 2 DESC;
    
                                   ## -----MEDIUM QUESTIONS-----##
# Question 1: Find all sales details for customers who are from cities ranked in the top 2.
  SELECT s.sale_id, s.sale_date, s.product_id, s.customer_id, 
  c.customer_name, s.total, s.rating , a.city_rank
  FROM sales AS s
  JOIN customers AS c ON s.customer_id = c.customer_id
  JOIN products AS p ON p.product_id = s.product_id
  JOIN city AS a ON a.city_id = c.city_id
  WHERE a.city_rank <= 2;
  
  
  # Question 2: Identify cities where the average rent is greater than $2,000 and total sales exceed $10,000.
  SELECT city_name, AVG (estimated_rent) AS average_rent,
  SUM(s.total) AS total_sales
  FROM sales AS s
  JOIN customers AS c ON s.customer_id = c.customer_id
  JOIN city AS a ON a.city_id = c.city_id
  GROUP BY city_name
  HAVING  AVG (a.estimated_rent) > 2000  AND SUM(s.total) > 10000;
  
  
  # Question 3: Calculate the percentage of total revenue contributed by each product.
  SELECT p.product_name, 
	SUM(s.total) AS product_revenue,
    (SUM(s.total) * 100 / (SELECT SUM(total) FROM sales)) AS revenue_percentage
  FROM sales s
  JOIN products AS p ON s.product_id = p.product_id
  GROUP BY p.product_name;
  
  
 # Question 4: List all products sold on '2023-01-01' along with their total sales and ratings.
SELECT p.product_name, s.sale_date, 
SUM(s.total) AS total_sales,
AVG(s.rating) AS avg_rating
FROM sales AS s
JOIN products AS p ON s.product_id = p.product_id
WHERE s.sale_date = '2023-01-01'
GROUP BY p.product_name;

#Question 5: Determine the correlation between city rank and total revenue generated in that city.
SELECT a.city_rank, SUM(s.total) AS total_revenue
FROM sales AS s
JOIN customers AS c ON s.customer_id = c.customer_id
JOIN city AS a ON a.city_id = c.city_id
GROUP BY a.city_rank
ORDER BY a.city_rank;


                     ##  ------ ADVANCE QUESTIONS ------  ##
# Question 1: Identify customers with high spending but low ratings (dissatisfied).
SELECT c.customer_name, SUM(s.total) AS total_spent,
AVG(s.rating) AS avg_rating
FROM sales s
JOIN customers AS c ON s.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING AVG(s.rating) < 3 AND SUM(s.total) > 50;

 # Question 2: Find Total Revenue Per City
SELECT a.city_name , sum(s.total) AS total_revenue
FROM city AS a
JOIN customers AS c ON a.city_id =  c.city_id
JOIN sales AS s ON s.customer_id = c.customer_id
GROUP BY a.city_name
ORDER BY total_revenue DESC;


# Question 3: Average Rent Per Customer Per City
SELECT a.city_name,
ROUND(SUM(a.estimated_rent) / 
COUNT(DISTINCT c.customer_id), 2) AS avg_rent_per_customer
FROM city a
JOIN customers c ON a.city_id = c.city_id
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY a.city_name
ORDER BY avg_rent_per_customer ASC; 

# Question 4: Find total customer,avergae sales per customer,total revenue on the basis of city.
SELECT a.city_name, COUNT(DISTINCT c.customer_id) AS total_customers,
    ROUND(SUM(s.total) / COUNT(DISTINCT c.customer_id), 2) AS avg_sales_per_customer,
	SUM(s.total) AS total_revenue
FROM city a
JOIN customers AS c ON a.city_id = c.city_id
JOIN sales AS s ON s.customer_id = c.customer_id
GROUP BY a.city_name 
ORDER BY total_revenue DESC; 

# Question 5: find cities with more customers, low total revenue, and low average ratings.
SELECT a.city_name,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    SUM(s.total) AS total_revenue,
	ROUND(AVG(s.rating), 2) AS avg_rating
    FROM city a
JOIN customers c ON a.city_id = c.city_id
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY a.city_name
HAVING total_revenue < 500000
    AND avg_rating <= 3.5 
ORDER BY total_customers DESC;

# Question 6: To find cities with more population, low total revenue and less customers.
SELECT a.city_name, a.population,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    SUM(s.total) AS total_revenue
FROM city a
LEFT JOIN customers c ON a.city_id = c.city_id
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY a.city_name, a.population
HAVING a.population > 1000000
    AND total_revenue < 500000 
    AND total_customers < 50   
ORDER BY  a.population DESC, total_revenue ASC;
   

/* Recomendation
City 1: Pune
	1.Average rent per customer is very low.
	2.Highest total revenue.
	3.Average sales per customer is also high.

City 2: Delhi
	1.Highest estimated coffee consumers at 7.7 million.
	2.Highest total number of customers, which is 68.
	3.Average rent per customer is 330 (still under 500).

City 3: Jaipur
	1.Highest number of customers, which is 69.
	2.Average rent per customer is very low at 156.
	3.Average sales per customer is better at 11.6k.

Improve Customer Satisfaction
Identify customers with low ratings but high spending. Address their concerns via personalized services or feedback collection.