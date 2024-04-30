--This part gets the total amount spent by each customer each year, and ranks the year and amount.
WITH customer_spent_per_year AS(
	SELECT customer_id, EXTRACT(YEAR FROM invoice_date) AS bill_year,
		SUM(total) AS total_spent,
  	RANK() OVER(PARTITION BY customer_id ORDER BY EXTRACT(YEAR FROM invoice_date)) AS year_rank,
  	RANK() OVER(PARTITION BY customer_id ORDER BY SUM(total)) AS bill_rank
	FROM customer
	INNER JOIN invoice
	USING(customer_id)
	WHERE EXTRACT(YEAR FROM invoice_date) != '2025'
	GROUP BY customer_id, EXTRACT(YEAR FROM invoice_date)),

/*This part counts the number of years each customer spent money,
but only when the year's rank matches the amount rank.*/
matching_records AS(
	SELECT customer_id, COUNT(*) AS num_of_years
	FROM customer_spent_per_year
	WHERE year_rank = bill_rank
	GROUP BY customer_id),

--This part counts the number of years each customer spent money.
all_records AS(
	SELECT customer_id, COUNT(*) AS num_of_years
	FROM customer_spent_per_year
  GROUP BY customer_id)

/*This part gets only the users that their year's count is the same.
The logic behind this is that as long as the rank matchs, it means the amount increases.
This way, a customer that only increased his spending will have the full count of years.*/
SELECT customer_id
FROM matching_records AS m
INNER JOIN all_records AS a
USING(customer_id)
WHERE m.num_of_years = a.num_of_years
ORDER BY customer_id;