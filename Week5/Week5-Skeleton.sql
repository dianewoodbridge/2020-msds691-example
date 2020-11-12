DROP TABLE nytimes_bestsellers;

--Ex 1. Create a table nytimes_bestsellers and insert nyt_bestsellers.json
-- What is the column type?


--Ex 2. From nytimes_bestsellers,
-- A. Return oid, author and amazon_url ordered by author name and oid.

-- B. Return the number of books written by "Alan Furst” in the table.



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
--Order it by date (ASC)


--Ex 4. 
-- Percentage of cash made by hour per plaza on November 10, 2016 (Inbound only).
-- 1) without window function

-- 2) with windows function


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


--Ex 6. 
-- a Find the most common color of boat reserved for each sailor's name ordered by sid.
-- (If a sailor never reserved a boat, the color and max column should be NULL.)

--b For each boat id, calculate the cumulative number of reservations.


--Ex 7. We are interested in how many unique sailors reserved a boat each year along with how many reservation was made quarterly.
-- The output should have cohort(1st day of the year), the number of unique sailors, reservation made between Jan-Mar, Apr-Jun, Jul-Sep and Oct-Dec.


--Ex 8
--a)Create a CTE called mta_inbound_vehicle which returns date, vehicle_cash and vehicle_ez for inbound only traffics.
--Return date, daily total of vehicle_cash and daily total of vehicle_ez ordered by date.

--b) Create a CTE called plaza_cumulative_hourly_vehicle_counts which returns date, hr, plaza_id, vehicle_ez, vehicle_cash,  and the cumulative sum of vehicle_ez  and the cumulative sum of vehicle_cash for the corresponding plaza_id for date. 
-- Return values when hr is 12.

-- Ex 9. In mta_no_index table, calculate  most common color of boat reserved for each sailor's name ordered by sid using CTE. 
-- Then, only return values for “Horatio”.
--Version 1)

--Version 2)


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


--Ex 11.
DROP VIEW IF EXISTS plaza_1_mta;

-- A. Create a view called plaza_1_mta for all the records where plaza_id is 1.

-- B. How many rows are in plaza_1_mta?

-- C. Insert (1, '2020-11-13', 9, 'O', 500, 400)  into plaza_1_mta.
-- How many rows are in plaza_1_mta?

-- D. In plaza_1_mta, update plaza_id to 2 where date = '2010-01-01' AND hr = 7 AND direction = ‘O’.
-- How many rows are in plaza_1_mta?

-- How to avoid this?

--E. Drop the mta_no_index table.

