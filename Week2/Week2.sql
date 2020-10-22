------------------------------------------------------------
-- EX 1. Create a table using the Iowa_Cars.csv.
-- You can assume that the combination of (year, county_name, vehicle_type, tonnage) is unique in the table.
------------------------------------------------------------
DROP TABLE IF EXISTS cars;

CREATE TABLE cars(
	year int
, year_ending date
, county_name varchar(20)
, county_code int
, feature_id int
, motorvehicle varchar(3)
, vehicle_cat varchar(15)
, vehicle_type varchar(45)
, tonnage varchar(30)
, registrations int
, annual_fee real
, primary_county_lat real
, primary_county_long real
, primary_county_cord varchar(45),
UNIQUE (year, county_name, vehicle_type, tonnage)
);

COPY cars FROM '/Users/dwoodbridge/Class/2020_MSDS691/Data/Iowa_Cars.csv' CSV HEADER;

------------------------------------------------------------
-- Ex 2. 
------------------------------------------------------------
-- A. Return county names in the cars table. (Duplicate allowed)
SELECT county_name FROM cars;
select County_Name from Cars;
Select COUNTY_NAME From CARS;
SELECT cOunty_nAme FROM cArs;

-- B. Return county_name and annual fees columns in the cars table. (Duplicate allowed)
SELECT county_name, annual_fee FROM cars;

-- C. Return all the columns in the cars table. (Duplicate allowed)
SELECT * FROM cars;

-- D. Return all unique years and vehicle_type in the cars table.
SELECT DISTINCT year, vehicle_type FROM cars;

------------------------------------------------------------
-- Ex 3. 
------------------------------------------------------------
-- A. Return all the records for “Semi Trailer” vehicles in the cars table. (Duplicate allowed)
SELECT *
FROM cars
WHERE vehicle_type = 'Semi Trailer';

SELECT *
FROM cars
WHERE vehicle_type = 'SEMI TRAILER';

-- B. Return all the records with more than 10000 registered vehicles in the cars table. (Duplicate allowed)
SELECT * FROM cars WHERE registrations > 10000;

------------------------------------------------------------
-- Ex 4. Return all the records for the Wright county 
-- where the registrations are between 1,200 and 3,000 (inclusive) or between 4,000 and 4,200 (inclusive).
------------------------------------------------------------
SELECT * FROM cars WHERE
(
(registrations > 1200 AND registrations <= 3000)
OR
(registrations > 4000 AND registrations <= 4200)
)
AND county_name = 'Wright';

------------------------------------------------------------
-- Ex 5. 
------------------------------------------------------------
-- A. Return top 5 records with the largest annual_fee.
SELECT *
FROM cars
WHERE cars.annual_fee IS NOT NULL
ORDER BY cars.annual_fee DESC
LIMIT 5;

-- B. Return the last 5 years in the table.
SELECT DISTINCT year
FROM cars
ORDER BY year DESC
LIMIT 5;


------------------------------------------------------------
-- Ex 6. 
------------------------------------------------------------
-- A. Find the unique integer values of primary_county_lat.
SELECT DISTINCT(CAST(primary_county_lat AS INTEGER))
FROM cars
WHERE primary_county_lat IS NOT NULL;

SELECT DISTINCT(primary_county_lat::INTEGER)
FROM cars
WHERE primary_county_lat IS NOT NULL;

-- B. Find the unique YEAR-MONTH pairs.
SELECT DISTINCT TO_CHAR(year_ending, 'YYYY-MM')
FROM cars
ORDER BY TO_CHAR;

------------------------------------------------------------
-- NULL
------------------------------------------------------------
SELECT NULL > 1;
SELECT NULL < 1;
SELECT NULL = 1;
SELECT NULL = NULL;

SELECT NULL AND True;
SELECT NULL OR True;
SELECT NULL AND False;
SELECT NULL OR False;

------------------------------------------------------------
-- Ex 7.
------------------------------------------------------------
-- A. Return all the records ordered by annual_fee when annual_fee is known.
SELECT *
FROM cars
WHERE cars.annual_fee IS NOT NULL
ORDER BY cars.annual_fee;

-- Ascending
SELECT *
FROM cars
WHERE cars.annual_fee IS NOT NULL
ORDER BY cars.annual_fee ASC;

-- Descending
SELECT *
FROM cars
WHERE cars.annual_fee IS NOT NULL
ORDER BY cars.annual_fee DESC;

-- B. Return all the records ordered by annual_fee (largest first), and then registration (largest first) when annual_fee is known.
SELECT *
FROM cars
WHERE annual_fee IS NOT NULL
ORDER BY annual_fee DESC, registrations DESC;

SELECT annual_fee, registrations
FROM cars
WHERE annual_fee IS NOT NULL
ORDER BY 1 DESC, 2 DESC;

SELECT annual_fee, registrations
FROM cars
WHERE annual_fee IS NOT NULL
ORDER BY annual_fee DESC, registrations DESC;

-- C. Find year, registrations, annual_fee for the records for more than 217,000 registrations and annual_fee is known. 
SELECT year, registrations, annual_fee
FROM cars
WHERE registrations > 217000 AND annual_fee IS NOT NULL;

------------------------------------------------------------
-- Ex 8. Assume that annual_fee for 2020 is 5% higher than 2019.
-- Return annual_fee_2019 and annual_fee_2020 for each county_name, vehicle_type and tonnage combination. 
-- Is the original table changed?
------------------------------------------------------------
SELECT county_name, vehicle_type, tonnage, annual_fee AS annual_fee_2019, annual_fee * 1.05 AS annual_fee_2020
FROM cars
WHERE year = 2019;

------------------------------------------------------------
-- Ex 9.
------------------------------------------------------------
-- A. Display “weight” in Kg from “tonnage” columns that include a string, “Tons”.
SELECT year, county_name, vehicle_type, TRIM(REPLACE(tonnage,'Tons','')) || '000 Kg' AS weight, annual_fee 
FROM cars
WHERE RIGHT(tonnage,4)='Tons'
ORDER BY year, country_name;

-- B. Find vehicle types that include a keyword, “truck” (case-insensitive).
SELECT DISTINCT vehicle_type
FROM cars
WHERE LOWER(vehicle_type) LIKE ('%truck%')

------------------------------------------------------------
-- Ex 10. For “Wright” county, calculate the smallest and largest value of 1) its original registration, 
-- 2) the absolute value of the original - 100, and 3) the absolute value of the original - 30, for registrations between 64 and 66.
------------------------------------------------------------
SELECT ABS(registrations - 100) AS c1
, ABS(registrations - 30) AS c2
, registrations
, LEAST( abs(registrations - 100), ABS(registrations - 30), registrations)
, GREATEST( abs(registrations - 100), ABS(registrations - 30), registrations)
FROM cars
WHERE registrations >= 64 AND registrations <= 66 AND county_name = 'Wright';

------------------------------------------------------------
-- Ex 11. Create a field called year_starting which is the first day of each year.
-- Return year_starting, year_ending, today's date, and age which is the difference between year_ending and today's date.
------------------------------------------------------------
SELECT  DISTINCT TO_DATE(year||'-01-01'::CHAR, 'YYYY-MM-DD') AS year_starting, year_ending, CURRENT_DATE,  (CURRENT_DATE - year_ending) AS age
FROM cars
ORDER BY year_starting;


------------------------------------------------------------
-- Ex 12. Find vehicle types that includes “Truck” but does not include “Tractor”.
------------------------------------------------------------
SELECT  DISTINCT vehicle_type
FROM cars
WHERE LOWER(vehicle_type) LIKE ('%truck%')
EXCEPT
SELECT  DISTINCT vehicle_type
FROM cars
WHERE LOWER(vehicle_type) LIKE ('%tractor%');

SELECT DISTINCT vehicle_type
FROM cars
WHERE LOWER(vehicle_type) LIKE ('%truck%') AND LOWER(vehicle_type) NOT LIKE ('%tractor%');

------------------------------------------------------------
-- Ex 13. 
------------------------------------------------------------
-- A. Return the unique year, county name, vehicle type, registrations where a vehicle type is 'Motor Home - A', 'Motor Home - B', 'Motor Home - C’, or 'Travel Trailer’.
-- Return the output ordered by 1) county name (ascending) and 2) registration (descending).
SELECT DISTINCT year, county_name, vehicle_type, registrations
FROM cars 
WHERE vehicle_type IN ('Motor Home - A', 'Motor Home - B', 'Motor Home - C', 'Travel Trailer')
ORDER BY county_name ASC, registrations DESC;

SELECT *
FROM  cars
WHERE registrations >= ALL (SELECT registrations FROM cars);

-- B. Return all the column values for the row that has the most registration.
SELECT *
FROM cars
WHERE EXISTS (SELECT *))


