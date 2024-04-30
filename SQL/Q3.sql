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