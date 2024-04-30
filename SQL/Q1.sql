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
