------------------------------------------------------------
--Ex 1. Create the sailors, boats, and reserves tables.
------------------------------------------------------------
DROP TABLE IF EXISTS sailors, boats, reserves CASCADE;

CREATE TABLE sailors(
	sid INTEGER PRIMARY KEY,
	sname VARCHAR(30),
	rating INTEGER,
	age REAL
	);
	
CREATE TABLE boats(
	bid INTEGER PRIMARY KEY,
	bname VARCHAR(30),
	color VARCHAR(20)
);

CREATE TABLE reserves(
	sid INTEGER,
	bid INTEGER,
	day DATE,
	PRIMARY KEY(sid, bid),
	FOREIGN KEY (sid) REFERENCES sailors(sid) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (bid) REFERENCES boats(bid) ON UPDATE CASCADE ON DELETE CASCADE
);

COPY sailors FROM '/Users/dwoodbridge/Class/2020_MSDS691/Data/sailors.csv' CSV HEADER;
COPY boats FROM '/Users/dwoodbridge/Class/2020_MSDS691/Data/boats.csv' CSV HEADER;
COPY reserves FROM '/Users/dwoodbridge/Class/2020_MSDS691/Data/reserves.csv' CSV HEADER;

SELECT * FROM sailors;
SELECT * FROM boats;
SELECT * FROM reserves;

------------------------------------------------------------
-- Ex 2. return sid, boat color (101 - blue, 103 - green, others are red) along with day from the reserves table.
------------------------------------------------------------
SELECT sid, CASE WHEN bid = 101 THEN 'blue' WHEN bid = 103 THEN 'green' ELSE 'red' END AS color, day
FROM reserves;

------------------------------------------------------------
-- Ex 3.
------------------------------------------------------------
-- A. Find the names of sailors who have reserved boat 103.
SELECT sailors.sname
FROM sailors
WHERE sailors.sid IN (SELECT reserves.sid FROM reserves WHERE reserves.bid = 103);

-- B. Find the names of sailors who have not reserve a red boat.
SELECT sailors.sname
FROM sailors
WHERE sailors.sid NOT IN (SELECT reserves.sid FROM reserves 
						  WHERE reserves.bid IN (SELECT boats.bid FROM boats WHERE boats.color = 'red'));

------------------------------------------------------------
-- Ex 4. Find the names of sailors who have reserved boat number 103.
------------------------------------------------------------
SELECT sailors.sname
FROM sailors
WHERE EXISTS (SELECT * FROM reserves WHERE sailors.sid = reserves.sid AND reserves.bid = 103);

------------------------------------------------------------
-- Ex 5.
------------------------------------------------------------
-- A. Find sailors whose rating is better than every sailor called Horatio.
SELECT *
FROM sailors AS s1
WHERE s1.rating > ALL (SELECT rating FROM sailors AS s2 WHERE s2.sname = 'Horatio');

-- B. Find sailors whose rating is better than some sailor called Horatio.
SELECT *
FROM sailors AS s1
WHERE s1.rating > ANY (SELECT s2.rating FROM sailors AS s2 WHERE s2.sname = 'Horatio');

-- C. Find the names of sailors who have reserved all boats.
SELECT sname
FROM sailors
WHERE NOT EXISTS(
SELECT bid FROM boats 
EXCEPT 
SELECT bid FROM reserves WHERE sailors.sid = reserves.sid);

------------------------------------------------------------
-- Ex 6.
------------------------------------------------------------
-- A. Find the average age of all sailors with a rating of 10.
SELECT AVG(sailors.age)
FROM sailors
WHERE sailors.rating = 10;

-- B. Find the name and age of the oldest sailor.
SELECT s1.sname, s1.age
FROM sailors s1
WHERE s1.age = (SELECT MAX(s2.age) FROM sailors s2);

-- C. Count the number of different sailor names.
SELECT COUNT(DISTINCT sailors.sname)
FROM sailors;

-- D. Find the names of sailors who are older than the oldest sailor with a rating of 10.
SELECT s1.sname
FROM sailors s1
WHERE s1.age > (SELECT MAX(s2.age) FROM sailors s2 where s2.rating = 10);

------------------------------------------------------------
-- Ex 7.
------------------------------------------------------------
-- A. Find the age of the youngest sailor who is eligible to vote (at least 18 years old) for each rating level with at least two such sailors.
SELECT sailors.rating, MIN(sailors.age)
FROM sailors
WHERE sailors.age >= 18
GROUP BY sailors.rating
HAVING COUNT(*) >= 2;

-- B. Find the average age of sailors who are of voting age for each rating level that has at least two such sailors.
SELECT sailors.rating, AVG(sailors.age)
FROM sailors
WHERE sailors.age >= 18
GROUP BY sailors.rating
HAVING COUNT(*) >= 2;

-- C. Find those ratings for which the average age of sailors is the minimum over all ratings.
SELECT sailors.rating, AVG(sailors.age)
FROM sailors
GROUP BY sailors.rating
HAVING AVG(sailors.age) = (SELECT MIN(avg_age) FROM (SELECT AVG(s2.age) as avg_age FROM sailors s2 GROUP BY s2.rating) AS avg);

SELECT avg.rating, avg.avg_age
FROM (SELECT s2.rating, AVG(s2.age) as avg_age
FROM sailors s2
GROUP BY s2.rating) AS avg
ORDER BY avg_age ASC
LIMIT 1;

-- D. For each red boat, find the number of reservations for this boat.
SELECT reserves.bid, COUNT(*) 
FROM reserves, boats
WHERE reserves.bid = boats.bid AND boats.color = 'red'
GROUP BY reserves.bid;

SELECT reserves.bid, COUNT(*) 
FROM reserves
JOIN boats
on boats.bid = reserves.bid
WHERE boats.color = 'red'
GROUP BY reserves.bid;

------------------------------------------------------------
-- Ex 8. We want to see monthly trend of the reservation between August and December. 
-- You can assume that there are data from several years.
-- Create a table that has August, September, October, November and December.
-- Rows should be the number of reservation made.
-- If there is no reservation record, it should be 0.
------------------------------------------------------------
SELECT GREATEST(0, SUM(august)) AS august, GREATEST(0, SUM(september)) AS september,
	   GREATEST(0, SUM(october)) AS october, GREATEST(0, SUM(november)) AS november,
	   GREATEST(0, SUM(december)) AS december
FROM
(
	SELECT CASE WHEN month = 8 THEN count END AS august, CASE WHEN month = 9 THEN count END AS september,
		   CASE WHEN month = 10 THEN count END AS october, CASE WHEN MONTH = 11 THEN count END AS november,
		   CASE WHEN month = 12 THEN count END AS december
	FROM(	
		SELECT month, COUNT(*)
		FROM (
			SELECT EXTRACT(MONTH FROM day) AS month
			FROM reserves
		) AS reserves_month
		WHERE month >= 8
		GROUP BY month
	) AS monthly_reserve
) AS sum_monthly_reserve;

------------------------------------------------------------
-- Ex 9.  We want to see monthly trend of the reservation between August and December per year. 
-- You can assume that there are data from several years.
-- Create a table that has August, September, October, November and December.
-- Rows should be the number of reservation made of each year, where the first column is year.
-- If there is no reservation record, it should be 0.
------------------------------------------------------------
SELECT year, GREATEST(0, SUM(august)), GREATEST(0, SUM(september)), GREATEST(0, SUM(october)), GREATEST(0, SUM(november)), GREATEST(0, SUM(december))
FROM
(
	SELECT year, CASE WHEN month = 8 THEN count END AS august, CASE WHEN month = 9 THEN count END AS september, 
		   CASE WHEN month = 10 THEN count END AS october, CASE WHEN month = 11 THEN count END AS november,
		   CASE WHEN month = 12 THEN count END AS december
	FROM
	(
		SELECT year, month, count(*) AS count
		FROM
		(
			SELECT sid, bid, EXTRACT(YEAR FROM day) AS year, EXTRACT(MONTH FROM day) AS month
			FROM reserves
			WHERE bid = 102
		) AS reserves_year_month
		GROUP BY year, month	
	) AS reserves_year_month_count
)AS reserves_year_aug_dec_count
GROUP BY year


------------------------------------------------------------
-- Ex 10.
------------------------------------------------------------
-- A. For each red boat, find the number of reservations for this boat.
SELECT reserves.bid, COUNT(*) 
FROM reserves
JOIN boats
on boats.bid = reserves.bid
WHERE boats.color = 'red'
GROUP BY reserves.bid;

-- B. For each sailor id, find the number of reservations.
SELECT sailor_reserve.sid, SUM(sailor_reserve.reserve_binary) AS reserve_count
FROM 
(
	SELECT sailors.sid, 
	 CASE 
	 WHEN bid IS NULL THEN 0
	 WHEN bid IS NOT NULL THEN 1
	 END reserve_binary
	 FROM sailors
	 LEFT JOIN reserves
	 ON sailors.sid = reserves.sid
) AS sailor_reserve
GROUP BY sailor_reserve.sid
ORDER BY reserve_count DESC, sailor_reserve.sid ASC;

-- C. Find the possible sailor id and boat id combinations.
SELECT sid, bid
FROM sailors
CROSS JOIN boats
ORDER BY sid, bid;

-- D. Find all possible sailor id and boat id combinations and the reserved dates. 
----- (If the sailor never reserved the boat, its date is NULL)
SELECT sailor_boats.sid, sailor_boats.bid, day
FROM 
(
	SELECT *
	FROM sailors
	CROSS JOIN boats
) sailor_boats
FULL OUTER JOIN reserves 
ON sailor_boats.sid = reserves.sid AND sailor_boats.bid = reserves.bid
ORDER BY sid, bid, day;

------------------------------------------------------------
-- Ex 11.
------------------------------------------------------------
-- A. Find the most common color of boat reserved for each sailor's name order by sid.
-- (If a sailor never reserved a boat, the color and max column should be NULL.)
SELECT reserved_boat_max_ct.sid, reserved_boat_ct_2.color, reserved_boat_max_ct.max
FROM 
(
	SELECT sid, MAX(ct)
	FROM 
	(
		SELECT sailors.sid, color, CASE WHEN color IS NULL THEN NULL ELSE count(*) END ct
		FROM sailors
		LEFT JOIN
		(
			SELECT boats.bid, boats.color, reserves.sid, reserves.day
			FROM boats
			JOIN reserves
			ON boats.bid = reserves.bid
		) AS reserved_boat
		ON sailors.sid = reserved_boat.sid
		GROUP BY sailors.sid, color
		ORDER BY ct DESC
	) AS reserved_boat_ct
	GROUP BY sid
) AS reserved_boat_max_ct
LEFT JOIN
(
	SELECT sailors.sid, color, CASE WHEN color IS NULL THEN NULL ELSE count(*) END ct
	FROM sailors
	LEFT JOIN
	(
		SELECT boats.bid, boats.color, reserves.sid, reserves.day
		FROM boats
		JOIN reserves
		ON boats.bid = reserves.bid
	) AS reserved_boat
	ON sailors.sid = reserved_boat.sid
	GROUP BY sailors.sid, color
	ORDER BY ct DESC
) AS reserved_boat_ct_2
ON reserved_boat_max_ct.sid = reserved_boat_ct_2.sid AND 
(reserved_boat_max_ct.max = reserved_boat_ct_2.ct)
ORDER BY sid;

-- B. For each boat id, calculate the cumulative number of reservations.
SELECT  reserve_day_sum_1.bid, reserve_day_sum_1.day,  SUM(reserve_day_sum_2.sum)
FROM	
(
	SELECT bid, day, SUM(ct) AS sum
	FROM 
		(SELECT bid, day, 1 AS ct
		FROM reserves) AS reserve_day_ct
	GROUP BY bid, day
) AS reserve_day_sum_1
JOIN
(
	SELECT bid, day, SUM(ct) AS sum
	FROM 
	(
		SELECT bid, day, 1 AS ct
		FROM reserves
	) AS reserve_day_ct
	GROUP BY bid, day
) AS reserve_day_sum_2
ON reserve_day_sum_1.bid = reserve_day_sum_2.bid 
   AND reserve_day_sum_1.day >= reserve_day_sum_2.day
GROUP BY reserve_day_sum_1.bid, reserve_day_sum_1.day
ORDER BY bid, day;

------------------------------------------------------------
-- Ex 12. We are interested in how many unique sailors reserved a boat each year along with how many reservation was made quarterly.
-- The output should have cohort(1st day of the year), the number of unique sailors, reservation made between Jan-Mar, Apr-Jun, Jul-Sep and Oct-Dec.
------------------------------------------------------------
SELECT cohort_monthly_count.cohort, unique_sailors, month_1_3, month_4_6, month_7_9, month_10_12
FROM
(
	SELECT cohort, COUNT(CASE WHEN cohort <= day AND CAST(day - cohort AS INTERVAL) <= CAST('3 months' AS INTERVAL) THEN 1 END) AS month_1_3,
	COUNT(CASE WHEN cohort + CAST('3 months' AS INTERVAL) < day AND CAST(day - cohort AS INTERVAL) <= CAST('6 months' AS INTERVAL) THEN 1 END) AS month_4_6,
	COUNT(CASE WHEN cohort + CAST('6 months' AS INTERVAL) < day AND CAST(day - cohort AS INTERVAL) <= CAST('9 months' AS INTERVAL) THEN 1 END) AS month_7_9,
	COUNT(CASE WHEN cohort + CAST('9 months' AS INTERVAL) < day AND CAST(day - cohort AS INTERVAL) <= CAST('12 months' AS INTERVAL) THEN 1 END) AS month_10_12
	FROM
	(
		SELECT DATE_TRUNC('year', day) AS cohort
		FROM reserves
		GROUP BY cohort
	) AS cohort
	LEFT JOIN reserves
	ON DATE_TRUNC('year', reserves.day)= cohort
	GROUP BY cohort
) AS cohort_monthly_count
LEFT JOIN
(
SELECT DATE_TRUNC('year', day) AS cohort, COUNT(DISTINCT sid) AS unique_sailors
FROM reserves
GROUP BY cohort
) AS cohort_unique_user
ON cohort_monthly_count.cohort = cohort_unique_user.cohort;
