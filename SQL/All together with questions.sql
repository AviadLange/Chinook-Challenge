/*
Question #1:
Write a solution to find the employee_id of managers with at least 2 direct reports.


Expected column names: employee_id

*/

-- q1 solution:

--This part filters for employees with at least 2 direct reports.
WITH reports_to_count AS(
	SELECT reports_to, COUNT(*) AS num_of_emp
	FROM employee
	GROUP BY reports_to
	HAVING  COUNT(*) > 1)

--This part gets only the desired managers.
SELECT employee_id
FROM employee AS e
INNER JOIN reports_to_count AS r
ON r.reports_to = e.employee_id
WHERE title LIKE '%Manager%'
ORDER BY employee_id;

/*

Question #2: 
Calculate total revenue for MPEG-4 video files purchased in 2024.

Expected column names: total_revenue

*/

-- q2 solution:

--This query gets the total revenue from MPEG-4 video files sold in 2024.
SELECT SUM(quantity*i.unit_price) AS total_revenue
FROM media_type
INNER JOIN track
USING(media_type_id)
INNER JOIN invoice_line AS i
USING(track_id)
INNER JOIN invoice
USING(invoice_id)
WHERE media_type_id = 3
	AND EXTRACT(YEAR FROM invoice_date) = '2024';

/*
Question #3: 
For composers appearing in classical playlists, count the number of distinct playlists they appear on and 
create a comma separated list of the corresponding (distinct) playlist names.

Expected column names: composer, distinct_playlists, list_of_playlists

*/

-- q3 solution:

--This query finds the classical composers and the playlists they are in.
SELECT composer, COUNT(DISTINCT p.name) AS distinct_playlists,
	STRING_AGG(p.name, ',') AS list_of_playlists --Concatenates the names.
FROM track 
INNER JOIN playlist_track
USING(track_id)
INNER JOIN playlist AS p
USING(playlist_id)
WHERE p.name LIKE '%Classical%'
	AND composer IS NOT NULL
GROUP BY composer;

/*
Question #4: 
Find customers whose yearly total spending is strictly increasing*.


*read the hints!


Expected column names: customer_id
*/

-- q4 solution:

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
