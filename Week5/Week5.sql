DROP TABLE nytimes_bestsellers;

--Ex 1. Create a table nytimes_bestsellers and insert nyt_bestsellers.json
-- What is the column type?
CREATE TABLE nytimes_bestsellers (bestseller JSON);
COPY nytimes_bestsellers FROM '/Users/dwoodbridge/Class/2020_MSDS691/Data/nyt_bestsellers.json';

SELECT *
FROM nytimes_bestsellers;

SELECT pg_typeof(bestseller) 
FROM nytimes_bestsellers;

--Ex 2. From nytimes_bestsellers,
-- A. Return oid, author and amazon_url ordered by author name and oid.
SELECT bestseller->'_id' FROM nytimes_bestsellers;

SELECT bestseller->'_id'->'$oid' AS oid, bestseller->'author' AS author, bestseller->'amazon_product_url' AS amzon_url 
FROM nytimes_bestsellers;

SELECT bestseller->'_id'->>'$oid' AS oid, bestseller->>'author' AS author, bestseller->>'amazon_product_url' AS amzon_url 
FROM nytimes_bestsellers
ORDER BY author, oid;

-- B. Return the number of books written by "Alan Furst” in the table.
SELECT COUNT(DISTINCT(bestseller->'_id'->>'$oid'))
FROM nytimes_bestsellers
WHERE bestseller->>'author' = 'Alan Furst';

--- Week4 mta_no_index table.
DROP TABLE IF EXISTS mta_no_index; 

CREATE TABLE mta_no_index (
	plaza_id INTEGER,
	date DATE,
	hr INTEGER,
	direction VARCHAR(1),
	vehicle_ez INTEGER,
	vehicle_cash INTEGER
);

COPY mta_no_index FROM '/Users/dwoodbridge/Class/2020_MSDS691/Data/NY_MTA.csv' CSV HEADER;

--Ex 3. Create rows of JSON include date, the total number of vehicle_ez and the total number of vehicle_cash per date.
-- Use the mta table from Week3.
-- Order it by date (ASC)
SELECT * FROM mta_no_index;
SELECT to_json(mta_no_index) FROM mta_no_index;
SELECT to_json(mta_summary) 
FROM (
	SELECT date, SUM(vehicle_ez) AS total_vehicle_ez, SUM(vehicle_cash) AS total_vehicle_cash
	FROM mta_no_index 
	GROUP BY date ORDER BY date) AS mta_summary;


--Ex 4. 
-- Percentage of cash made by hour per plaza on November 10, 2016 (Inbound only).
-- 1) without window function
SELECT mta_no_index.plaza_id, mta_no_index.hr, 100*vehicle_cash::float/ total_plaza_cash
FROM mta_no_index
LEFT JOIN (SELECT plaza_id,  SUM(vehicle_cash) as total_plaza_cash
FROM mta_no_index
WHERE date = '2016-11-10' AND direction = 'I' 
GROUP BY plaza_id) AS agg_mta
ON mta_no_index.plaza_id = agg_mta.plaza_id
WHERE date = '2016-11-10' AND direction = 'I'
ORDER BY mta_no_index.plaza_id, mta_no_index.hr;

-- 2) with windows function
SELECT plaza_id, hr, vehicle_cash
FROM mta_no_index
WHERE date = '2016-11-10' AND direction = 'I'
ORDER BY plaza_id, hr;

SELECT plaza_id,  SUM(vehicle_cash)
FROM mta_no_index
WHERE date = '2016-11-10' AND direction = 'I' 
GROUP BY plaza_id
ORDER BY plaza_id;

SELECT plaza_id, hr, vehicle_cash, sum(vehicle_cash) OVER (PARTITION BY plaza_id)
FROM mta_no_index
WHERE date = '2016-11-10' AND direction = 'I'
ORDER BY plaza_id, hr;

SELECT plaza_id, hr, 100 * vehicle_cash::float/sum(vehicle_cash) OVER (PARTITION BY plaza_id)
FROM mta_no_index
WHERE date = '2016-11-10' AND direction = 'I'
ORDER BY plaza_id, hr;

--P.22
SELECT plaza_id, hr, vehicle_cash, 
	   SUM(hr) OVER(), 
	   SUM(hr) OVER (PARTITION BY plaza_id), 
	   SUM(hr) OVER (PARTITION BY plaza_id ORDER BY hr),
	   SUM(hr) OVER (PARTITION BY plaza_id ORDER BY hr ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING),
	   SUM(hr) OVER (PARTITION BY plaza_id ORDER BY hr ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING),
	   SUM(hr) OVER (PARTITION BY plaza_id ORDER BY hr ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
FROM mta_no_index
WHERE date = '2016-11-10' AND direction = 'I'
ORDER BY plaza_id, hr;


--Ex 5. Calculate correlation between the absolute hourly change in vehicle paying cash and the absolute hourly change in vehicles paying by EZ-pass?

SELECT CORR(ez_diff, cash_diff)
FROM
(
SELECT plaza_id, date, hr, vehicles_ez, ABS(LAG(vehicles_ez) OVER (PARTITION BY plaza_id ORDER BY date, hr) - vehicles_ez) AS ez_diff,
 vehicles_cash, ABS(LAG(vehicles_cash) OVER (PARTITION BY plaza_id ORDER BY date, hr) - vehicles_cash) AS cash_diff
FROM mta
) AS diff

--Ex 6. 
-- a Find the most common color of boat reserved for each sailor's name ordered by sid.
-- (If a sailor never reserved a boat, the color and max column should be NULL.)
SELECT sailors.sid, color, count
FROM sailors
LEFT JOIN
(
	SELECT DISTINCT
	FIRST_VALUE(sid) OVER (PARTITION BY sid ORDER BY count DESC) AS sid,
	FIRST_VALUE(color) OVER (PARTITION BY sid ORDER BY count DESC) AS color,
	FIRST_VALUE(count) OVER (PARTITION BY sid ORDER BY count DESC) AS count
	FROM 
		(
		SELECT reserves.sid, color, COUNT(*)
		FROM reserves
		JOIN boats
		ON reserves.bid = boats.bid
		GROUP BY reserves.sid, color
		) AS sid_color_count
) AS sid_max_color_count
ON sid_max_color_count.sid = sailors.sid
ORDER BY sid;

--b For each boat id, calculate the cumulative number of reservations.
SELECT bid, day, COUNT(*) OVER (PARTITION BY bid ORDER BY day)
FROM reserves

--Ex 7. We are interested in how many unique sailors reserved a boat each year along with how many reservation was made quarterly.
-- The output should have cohort(1st day of the year), the number of unique sailors, reservation made between Jan-Mar, Apr-Jun, Jul-Sep and Oct-Dec.
SELECT year_sid_count.year AS cohort, count, mon_1_3, mon_4_6, mon_4_6, mon_7_9, mon_10_12
FROM
(
	SELECT COUNT(*), year
	FROM (
	SELECT DISTINCT sid, EXTRACT(YEAR from day) AS year
	FROM reserves
	) AS yearly_unique_sid
	GROUP BY year
) AS year_sid_count
JOIN
(
	SELECT year, SUM(mon_1_3) AS mon_1_3, SUM(mon_4_6) AS mon_4_6, SUM(mon_7_9) AS mon_7_9, SUM(mon_10_12) AS mon_10_12
	FROM
	(
		SELECT EXTRACT(YEAR FROM first_reserve_month) AS year, 
		CASE WHEN EXTRACT(MONTH FROM first_reserve_month) <= 3 THEN monthly_count END AS mon_1_3, 
		CASE WHEN EXTRACT(MONTH FROM first_reserve_month) > 3 AND EXTRACT(MONTH FROM first_reserve_month) <= 6 THEN monthly_count END AS mon_4_6, 
		CASE WHEN EXTRACT(MONTH FROM first_reserve_month) > 6 AND EXTRACT(MONTH FROM first_reserve_month) <= 9 THEN monthly_count END AS mon_7_9,  
		CASE WHEN EXTRACT(MONTH FROM first_reserve_month) > 9 AND EXTRACT(MONTH FROM first_reserve_month) <= 12 THEN monthly_count END AS mon_10_12
		FROM
		(
		SELECT DISTINCT FIRST_VALUE(day) OVER (PARTITION BY EXTRACT(YEAR from day), EXTRACT(MONTH from day)) AS first_reserve_month, 						 COUNT(*) OVER (PARTITION BY EXTRACT(YEAR from day), EXTRACT(MONTH from day)) AS monthly_count
		FROM reserves
		) AS first_reserve_month_count
	) AS monthly_reserve_count
	GROUP BY year
) AS cohort_sum
ON year_sid_count.year = cohort_sum.year

--Ex 8
--a)Create a CTE called mta_inbound_vehicle which returns date, vehicle_cash and vehicle_ez for inbound only traffics.
--Return date, daily total of vehicle_cash and daily total of vehicle_ez ordered by date.
WITH mta_inbound_vehicle AS (SELECT date, vehicle_cash, vehicle_ez FROM mta_no_index WHERE direction = 'I')
SELECT date, SUM(vehicle_cash), SUM(vehicle_ez)
FROM mta_inbound_vehicle
GROUP by date
ORDER by date;

--b) Create a CTE called plaza_cumulative_hourly_vehicle_counts which returns date, hr, plaza_id, vehicle_ez, vehicle_cash,  and the cumulative sum of vehicle_ez  and the cumulative sum of vehicle_cash for the corresponding plaza_id for date. 
-- Return values when hr is 12.
WITH plaza_cumulative_hourly_vehicle_counts AS
(
	SELECT plaza_id, date, hr, vehicle_ez, vehicle_cash,
	SUM(vehicle_ez) OVER (PARTITION BY plaza_id, date ORDER BY hr) AS vehicle_ez_sum,
	SUM(vehicle_cash) OVER (PARTITION BY plaza_id, date ORDER BY hr) AS vehicle_cash_sum
	FROM mta_no_index
	WHERE direction = 'I'
)
SELECT *
FROM plaza_cumulative_hourly_vehicle_counts
WHERE hr = 12;

-- Ex 9. In mta_no_index table, calculate  most common color of boat reserved for each sailor's name ordered by sid using CTE. 
-- Then, only return values for “Horatio”.
--Version 1)
WITH sid_common_color_count AS
(
	SELECT sailors.sid, sname, color, count
	FROM sailors
	LEFT JOIN
	(
		SELECT DISTINCT
		FIRST_VALUE(sid) OVER (PARTITION BY sid ORDER BY count DESC) AS sid,
		FIRST_VALUE(color) OVER (PARTITION BY sid ORDER BY count DESC) AS color,
		FIRST_VALUE(count) OVER (PARTITION BY sid ORDER BY count DESC) AS count
		FROM 
			(
			SELECT reserves.sid, color, COUNT(*)
			FROM reserves
			JOIN boats
			ON reserves.bid = boats.bid
			GROUP BY reserves.sid, color
			) AS sid_color_count
	) AS sid_max_color_count
	ON sid_max_color_count.sid = sailors.sid
)
SELECT * 
FROM sid_common_color_count
WHERE sname = 'Horatio';

--Version 2)
WITH sid_name AS
(
	SELECT 	sid, sname
	FROM sailors
),
sid_color_count AS
(
	SELECT reserves.sid, color, COUNT(*)
	FROM reserves
	JOIN boats
	ON reserves.bid = boats.bid
	GROUP BY reserves.sid, color
),
sid_common_color_count AS
(
	SELECT sid_name.sid, sname, color, count
	FROM sid_name
	LEFT JOIN
	(
		SELECT DISTINCT
		FIRST_VALUE(sid) OVER (PARTITION BY sid ORDER BY count DESC) AS sid,
		FIRST_VALUE(color) OVER (PARTITION BY sid ORDER BY count DESC) AS color,
		FIRST_VALUE(count) OVER (PARTITION BY sid ORDER BY count DESC) AS count
		FROM sid_color_count
	) AS sid_max_color_count
	ON sid_max_color_count.sid = sid_name.sid
)
SELECT * 
FROM sid_common_color_count
WHERE sname = 'Horatio';

-- p.32
CREATE OR REPLACE FUNCTION increment(input int) 
RETURNS int AS 
$$ SELECT input + 1 $$ 
LANGUAGE SQL;

SELECT * FROM increment(42);

DROP FUNCTION IF EXISTS increment;

-- Ex 10. In mta_no_index table, calculate  most common color of boat reserved for each sailor's name ordered by sid using functions and CTE. 
-- Then, only return values for “Horatio”.
-- In order to improve the search time, filter out the name first using a function.

CREATE OR REPLACE FUNCTION  sid_for_name(name VARCHAR) 
RETURNS TABLE (sid INTEGER, sname VARCHAR) AS
$$
	SELECT 	sid, sname
	FROM sailors
	WHERE sname = name
$$
LANGUAGE SQL;

CREATE OR REPLACE FUNCTION sid_most_common_color_count(name VARCHAR)
RETURNS TABLE (sid INTEGER, sname VARCHAR, color VARCHAR, count BIGINT) AS
$$
WITH 
sid_color_count AS
(
	SELECT reserves.sid, color, COUNT(*)
	FROM reserves
	JOIN boats
	ON reserves.bid = boats.bid AND reserves.sid IN (SELECT sid FROM sid_for_name(name))
	GROUP BY reserves.sid, color
),
sid_common_color_count AS
(
	SELECT sid_name.sid, sname, color, count
	FROM sid_for_name(name) AS sid_name
	LEFT JOIN
	(
		SELECT DISTINCT
		FIRST_VALUE(sid) OVER (PARTITION BY sid ORDER BY count DESC) AS sid,
		FIRST_VALUE(color) OVER (PARTITION BY sid ORDER BY count DESC) AS color,
		FIRST_VALUE(count) OVER (PARTITION BY sid ORDER BY count DESC) AS count
		FROM sid_color_count
	) AS sid_max_color_count
	ON sid_max_color_count.sid = sid_name.sid 
)
SELECT * 
FROM sid_common_color_count
$$ LANGUAGE SQL;

SELECT * FROM sid_most_common_color_count('Horatio');

DROP FUNCTION IF EXISTS sid_for_name;
DROP FUNCTION IF EXISTS sid_most_common_color_count;

--Ex 11.
DROP VIEW IF EXISTS plaza_1_mta;

-- A. Create a view called plaza_1_mta for all the records where plaza_id is 1.
CREATE VIEW plaza_1_mta AS
SELECT *
FROM mta_no_index
WHERE plaza_id = 1;

-- B. How many rows are in plaza_1_mta?
SELECT COUNT(*) FROM plaza_1_mta;

-- C. Insert (1, '2020-11-13', 9, 'O', 500, 400)  into plaza_1_mta.
-- How many rows are in plaza_1_mta?
INSERT INTO mta_no_index VALUES(1, '2020-11-13', 9, 'O', 500, 400);
SELECT COUNT(*) FROM plaza_1_mta;

-- D. In plaza_1_mta, update plaza_id to 2 where date = '2010-01-01' AND hr = 7 AND direction = ‘O’.
-- How many rows are in plaza_1_mta?
UPDATE plaza_1_mta
SET plaza_id = 2
WHERE date = '2010-01-01' AND hr = 7 AND direction = 'O';

SELECT COUNT(*) FROM plaza_1_mta;

-- How to avoid this?
CREATE OR REPLACE VIEW plaza_1_mta AS
SELECT *
FROM mta_no_index
WHERE plaza_id = 1 WITH CHECK OPTION;

UPDATE plaza_1_mta
SET plaza_id = 2
WHERE date = '2010-01-01' AND hr = 8 AND direction = 'O';

--E. Drop the mta_no_index table.
DROP TABLE IF EXISTS mta_no_index;
DROP TABLE IF EXISTS mta_no_index CASCADE; 