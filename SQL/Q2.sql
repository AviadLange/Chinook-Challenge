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