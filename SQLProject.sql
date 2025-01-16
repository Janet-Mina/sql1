--Creating aisles table
	CREATE TABLE aisle(
		aisle_id INT PRIMARY KEY,
		aisle VARCHAR(50) NOT NULL
	);
	
--Creating departments table
	CREATE TABLE department(
		department_id INT PRIMARY KEY,
		department VARCHAR(30) NOT NULL
	);
	
--Creating products tables
	CREATE TABLE product(
		product_id INT PRIMARY KEY,
		product_name VARCHAR(200) NOT NULL,
		aisle_id INT REFERENCES aisle(aisle_id),
		department_id INT REFERENCES department(department_id),
		unit_cost NUMERIC(10,2),
		unit_price NUMERIC(10,2)
	);
	
--Creating orders table
	CREATE TABLE orders(
		order_id INT PRIMARY KEY,
		user_id INT,
		product_id INT REFERENCES product(product_id),
		quantity INT,
		order_date DATE,
		order_day_of_week INT,
		order_hour_of_day INT,
		days_since_prior_order INT,
		order_status VARCHAR(30)
	);
	
	
	
/*Create a Database with the provided datasets from InstaCart and 
answer the following business questions: 
NOTE: order_dow means order day of week ie 0 = Sunday, 1 = Monday
*/


--Q1 What are the top-selling products by revenue, and how much revenue have they generated?

SELECT p.product_name,
	' $ ' || SUM(p.unit_price*o.quantity) AS revenue
	FROM product AS p
	JOIN orders AS o ON o.product_id = p.product_id
	GROUP BY p.product_name
	ORDER BY  SUM(p.unit_price*o.quantity)  DESC;


--Q2 On which day of the week are chocolates mostly sold?
SELECT 
		CASE
			WHEN o.order_day_of_week = 0 THEN 'Sunday'
			WHEN o.order_day_of_week = 1 THEN 'Monday'
			WHEN o.order_day_of_week = 2 THEN 'Tuesday'
			WHEN o.order_day_of_week = 3 THEN 'Wednesday'
			WHEN o.order_day_of_week = 4 THEN 'Thursday'
			WHEN o.order_day_of_week = 5 THEN 'Friday'
			ELSE 'Saturday'
			END AS day_of_week,
	SUM(o.quantity) AS chocolates_sold
	FROM product AS p
	JOIN orders AS o ON o.product_id = p.product_id
	WHERE product_name ILIKE '%Chocolate%'
	GROUP BY  p.product_name,
		    o.order_day_of_week
ORDER BY chocolates_sold DESC
LIMIT 1;


--Q3 Do we have any dept where we have made over $15m in revenue and what is the profit?

SELECT d.department,
	'$' || SUM(p.unit_price*o.quantity) AS revenue,
	'$' || SUM((p.unit_price-p.unit_cost)* o.quantity) AS profit
	FROM orders AS o
	JOIN product AS p ON p.product_id = o.product_id
	JOIN department AS d ON d.department_id = p.department_id
	GROUP BY d.department
	HAVING SUM(p.unit_price*o.quantity) > 15000000
	ORDER BY SUM(p.unit_price*o.quantity), SUM((p.unit_price-p.unit_cost)* o.quantity);

--Yes, 7 departments made over $15m as revenue.

--Q4 Is it true that customers buy more alcoholic products on Xmas day 2019?
SELECT d.department,
	SUM(o.quantity) AS Qty_of_alcohol
	FROM product AS p
	JOIN orders AS o ON o.product_id = p.product_id
	JOIN department AS d ON d.department_id = p.department_id 
	WHERE o.order_date = '2019-12-25'
	GROUP BY d.department
	ORDER BY  Qty_of_alcohol DESC;

---No, Customers bought more snacks on xmas day in terms of quantity sold.

--Q5 Which year did Instacart generate the most profit?

SELECT EXTRACT(YEAR FROM o.order_date) AS years,
	'$' || SUM((p.unit_price-p.unit_cost)*o.quantity) AS profit
	FROM orders AS o
	JOIN product AS p ON p.product_id = o.product_id
	GROUP BY  EXTRACT(YEAR FROM o.order_date)
	ORDER BY  SUM((p.unit_price-p.unit_cost)*o.quantity) DESC
	LIMIT 1;


--Q6 How long has it been since the last cheese order?
SELECT
	CURRENT_DATE - MAX(o.order_date) AS last_cheese_order
	FROM orders AS o
	JOIN product AS p ON p.product_id = o.product_id
	WHERE product_name = 'Cheese';


--Q7 What time of the day do we sell alcohols the most?

SELECT o.order_hour_of_day,
	CASE
	WHEN o.order_hour_of_day BETWEEN 0 AND 11 THEN 'Morning'  -- Where 0 = 12am, also assuming morning starts from 12am to 11am
	WHEN o.order_hour_of_day BETWEEN 12 AND 17 THEN 'Afternoon'  --Where 17= 5pm, also assuming afternoon starts from 12pm to 5pm
	ELSE 'Night'
	END AS time_of_the_day,
	SUM(o.quantity) AS qty_of_alcohol_sold
	FROM product AS p
	JOIN orders AS o ON o.product_id = p.product_id
	JOIN department AS d ON d.department_id = p.department_id 
	WHERE d.department = 'alcohol'
	GROUP BY  o.order_hour_of_day
	ORDER BY  qty_of_alcohol_sold DESC
	LIMIT 1;


--Q8 What is the total revenue generated in Qtr. 2 & 3 of 2016 from breads?

SELECT
' $ ' || SUM(p.unit_price*o.quantity) AS total_revenue
	FROM aisle AS a
	JOIN product AS p ON p.aisle_id = a.aisle_id
	JOIN orders AS o ON o.product_id = p.product_id
	WHERE a.aisle = 'bread' AND o.order_date BETWEEN '2016-04-01' AND '2016-09-30';


--Q9 Which 3  products do people buy at night(2020 - 2022)?

SELECT p.product_name,
	SUM(o.quantity) AS total_quantity_ordered
	FROM product AS p
	JOIN orders AS o ON o.product_id = p.product_id
	WHERE o.order_hour_of_day BETWEEN 18 AND 23 --- night time starts from 18-23hours (6pm-11pm)
	AND o.order_date BETWEEN '2020-01-01'AND '2022-12-31'
	GROUP BY p.product_name
	ORDER BY total_quantity_ordered DESC
	LIMIT 3;


--Q10 What is the total revenue generated from juice products?
SELECT
	'$' || SUM(p.unit_price*o.quantity) AS total_revenue
	FROM orders AS o
	JOIN product AS p ON p.product_id = o.product_id
	WHERE p.product_name ILIKE '%juice%';




	