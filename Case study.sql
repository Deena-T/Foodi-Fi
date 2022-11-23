DROP TABLE IF EXISTS plans;
CREATE TABLE plans (
plan_id INT,
plan_name TEXT,
price DECIMAL(5,2));

INSERT INTO plans VALUES
(0, "trial", 0), (1, "basic monthly", "9.90"), (2, "pro monthly", "19.90"), (3, "pro annual", "199"),
(4, "churn", null);

DROP TABLE IF EXISTS subscriptions;
CREATE TABLE subscriptions (
customer_id INT,
plan_id INT,
start_date DATE);

INSERT INTO subscriptions VALUES
 ('1', '0', '2020-08-01'),
  ('1', '1', '2020-08-08'),
  ('2', '0', '2020-09-20'),
  ('2', '3', '2020-09-27'),
  ('3', '0', '2020-01-13'),
  ('3', '1', '2020-01-20'),
  ('4', '0', '2020-01-17'),
  ('4', '1', '2020-01-24'),
  ('4', '4', '2020-04-21'),
  ('5', '0', '2020-08-03'),
  ('5', '1', '2020-08-10'),
  ('6', '0', '2020-12-23'),
  ('6', '1', '2020-12-30'),
  ('6', '4', '2021-02-26'),
  ('7', '0', '2020-02-05'),
  ('7', '1', '2020-02-12'),
  ('7', '2', '2020-05-22'),
  ('8', '0', '2020-06-11'),
  ('8', '1', '2020-06-18'),
  ('8', '2', '2020-08-03'),
  ('9', '0', '2020-12-07'),
  ('9', '3', '2020-12-14'),
  ('10', '0', '2020-09-19'),
  ('10', '2', '2020-09-26'),
  ('11', '0', '2020-11-19'),
  ('11', '4', '2020-11-26'),
  ('12', '0', '2020-09-22'),
  ('12', '1', '2020-09-29'),
  ('13', '0', '2020-12-15'),
  ('13', '1', '2020-12-22'),
  ('13', '2', '2021-03-29'),
  ('14', '0', '2020-09-22'),
  ('14', '1', '2020-09-29'),
  ('15', '0', '2020-03-17'),
  ('15', '2', '2020-03-24'),
  ('15', '4', '2020-04-29'),
  ('16', '0', '2020-05-31'),
  ('16', '1', '2020-06-07'),
  ('16', '3', '2020-10-21'),
  ('17', '0', '2020-07-27'),
  ('17', '1', '2020-08-03'),
  ('17', '3', '2020-12-11'),
  ('18', '0', '2020-07-06'),
  ('18', '2', '2020-07-13'),
  ('19', '0', '2020-06-22'),
  ('19', '2', '2020-06-29'),
  ('19', '3', '2020-08-29'),
 ('20', '0', '2020-02-04'),
  ('20', '1', '2020-02-11'),
  ('20', '2', '2020-06-03'),
  ('20', '4', '2020-09-27');
  -------------------------------------------------------------
  -- Customer 1
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM subscriptions
JOIN plans USING (plan_id)
WHERE customer_id =1;
---------------------------------------------------------------------------
-- Customer 20
SELECT customer_id,
       plan_id,
       plan_name,
       start_date
FROM subscriptions
JOIN plans USING (plan_id)
WHERE customer_id =20;
 ---------------------------------------------------------------------------------------------------------- 
-- Q1  
SELECT 
  COUNT(DISTINCT customer_id) AS no_of_customer
FROM subscriptions;
---------------------------------------------------------------------
-- Q2
SELECT month(start_date),
       count(DISTINCT customer_id) as 'Monthly Distribution'
FROM subscriptions
JOIN plans USING (plan_id)
WHERE plan_id=0
GROUP BY month(start_date);
--------------------------------------------------------------------
-- Q3
SELECT plan_id,
       plan_name,
       count(*) AS 'count of events'
FROM subscriptions
JOIN plans USING (plan_id)
WHERE year(start_date) > 2020
GROUP BY plan_id;

--------------------------------------------------------------------------------
-- Q4
SELECT
   count(*) AS Customer_churn,
   ROUND(COUNT(*) * 100 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS percentage_churn
FROM subscriptions
WHERE plan_id =4;   
----------------------------------------------------------------------------------
-- Q6
SELECT plan_name,
       count(customer_id) No_of_Customer,
       round(100 *count(DISTINCT customer_id) /
               (SELECT count(DISTINCT customer_id) AS 'distinct customers'
                FROM subscriptions), 2) AS 'Percentage_of_Customer'
FROM subscriptions
JOIN plans USING (plan_id)
WHERE plan_name != 'trial'
GROUP BY plan_name
ORDER BY plan_id;
-------------------------------------------------------------------------------------------
-- Q8
SELECT plan_id,
       COUNT(DISTINCT customer_id) AS Annual_Plan_Customer_Count
FROM subscriptions
WHERE plan_id = 3
  AND year(start_date) = 2020;

  ---------------------------------------------------------------------------------
  -- Q11
SELECT COUNT(*) AS customers_downgraded
FROM subscriptions
WHERE plan_id=2 AND plan_id=1;
-------------------------------------------------------------------------
-- Q9
WITH annual_plan AS (
	SELECT
		customer_id,
        start_date AS annual_date
	FROM subscriptions
    	WHERE plan_id = 3),
trial_plan AS (
	SELECT
		customer_id,
        start_date AS trial_date
	FROM subscriptions
    WHERE plan_id = 0
)
SELECT
	ROUND(AVG(DATEDIFF(annual_date, trial_date)),0) AS avg_days_upgrade
FROM annual_plan ap
JOIN trial_plan tp ON ap.customer_id = tp.customer_id;
-------------------------------------------------------------------------------------------
--- Q7
WITH latest_plan_cte AS
  (SELECT *,
          row_number() over(PARTITION BY customer_id
                            ORDER BY start_date DESC) AS latest_plan
   FROM subscriptions
   JOIN plans USING (plan_id)
   WHERE start_date <='2020-12-31' )
SELECT plan_id,
       plan_name,
       count(customer_id) AS customer_count,
       round(100*count(customer_id) /
               (SELECT COUNT(DISTINCT customer_id)
                FROM subscriptions), 2) AS percentage_breakdown
FROM latest_plan_cte
WHERE latest_plan = 1
GROUP BY plan_id
ORDER BY plan_id;




  

  
  