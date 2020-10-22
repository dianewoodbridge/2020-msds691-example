------------------------------------------------------------
-- EX 1. Create a table using the Iowa_Cars.csv.
-- You can assume that the combination of (year, county_name, vehicle_type, tonnage) is unique in the table.
------------------------------------------------------------


------------------------------------------------------------
-- Ex 2. 
------------------------------------------------------------
-- A. Return county names in the cars table. (Duplicate allowed)

-- B. Return county_name and annual fees columns in the cars table. (Duplicate allowed)

-- C. Return all the columns in the cars table. (Duplicate allowed)

-- D. Return all unique years and vehicle_type in the cars table.


------------------------------------------------------------
-- Ex 3. 
------------------------------------------------------------
-- A. Return all the records for “Semi Trailer” vehicles in the cars table. (Duplicate allowed)

-- B. Return all the records with more than 10000 registered vehicles in the cars table. (Duplicate allowed)


------------------------------------------------------------
-- Ex 4. Return all the records for the Wright county 
-- where the registrations are between 1,200 and 3,000 (inclusive) or between 4,000 and 4,200 (inclusive).
------------------------------------------------------------


------------------------------------------------------------
-- Ex 5. 
------------------------------------------------------------
-- A. Return top 5 records with the largest annual_fee.

-- B. Return the last 5 years in the table.


------------------------------------------------------------
-- NULL
------------------------------------------------------------


------------------------------------------------------------
-- Ex 6. 
------------------------------------------------------------
-- A. Find the unique integer values of primary_county_lat.

-- B. Find the unique YEAR-MONTH pairs.


------------------------------------------------------------
-- Ex 7.
------------------------------------------------------------
-- A. Return all the records ordered by annual_fee when annual_fee is known.

-- Ascending

-- Descending

-- B. Return all the records ordered by annual_fee (largest first), and then registration (largest first) when annual_fee is known.

-- C. Find year, registrations, annual_fee for the records for more than 217,000 registrations and annual_fee is known. 


------------------------------------------------------------
-- Ex 8. Assume that annual_fee for 2020 is 5% higher than 2019.
-- Return annual_fee_2019 and annual_fee_2020 for each county_name, vehicle_type and tonnage combination. 
-- Is the original table changed?
------------------------------------------------------------


------------------------------------------------------------
-- Ex 9.
------------------------------------------------------------
-- A. Display “weight” in Kg from “tonnage” columns that include a string, “Tons”.

-- B. Find vehicle types that include a keyword, “truck” (case-insensitive).


------------------------------------------------------------
-- Ex 10. For “Wright” county, calculate the smallest and largest value of 1) its original registration, 
-- 2) the absolute value of the original - 100, and 3) the absolute value of the original - 30, for registrations between 64 and 66.
------------------------------------------------------------


------------------------------------------------------------
-- Ex 11. Create a field called year_starting which is the first day of each year.
-- Return year_starting, year_ending, today's date, and age which is the difference between year_ending and today's date.
------------------------------------------------------------


------------------------------------------------------------
-- Ex 12. Find vehicle types that includes “Truck” but does not include “Tractor”.
------------------------------------------------------------


------------------------------------------------------------
-- Ex 13. 
------------------------------------------------------------
-- A. Return the unique year, county name, vehicle type, registrations where a vehicle type is 'Motor Home - A', 'Motor Home - B', 'Motor Home - C’, or 'Travel Trailer’.
-- Return the output ordered by 1) county name (ascending) and 2) registration (descending).

-- B. Return all the column values for the row that has the most registration.

