------------------------------------------------------------
--Ex 1. Create the sailors, boats, and reserves tables.
------------------------------------------------------------


------------------------------------------------------------
-- Ex 2. return sid, boat color (101 - blue, 103 - green, others are red) along with day from the reserves table.
------------------------------------------------------------


------------------------------------------------------------
-- Ex 3.
------------------------------------------------------------
-- A. Find the names of sailors who have reserved boat 103.

-- B. Find the names of sailors who have not reserve a red boat.


------------------------------------------------------------
-- Ex 4. Find the names of sailors who have reserved boat number 103.
------------------------------------------------------------

------------------------------------------------------------
-- Ex 5.
------------------------------------------------------------
-- A. Find sailors whose rating is better than every sailor called Horatio.

-- B. Find sailors whose rating is better than some sailor called Horatio.

-- C. Find the names of sailors who have reserved all boats.


------------------------------------------------------------
-- Ex 6.
------------------------------------------------------------
-- A. Find the average age of all sailors with a rating of 10.

-- B. Find the name and age of the oldest sailor.

-- C. Count the number of different sailor names.

-- D. Find the names of sailors who are older than the oldest sailor with a rating of 10.


------------------------------------------------------------
-- Ex 7.
------------------------------------------------------------
-- A. Find the age of the youngest sailor who is eligible to vote (at least 18 years old) for each rating level with at least two such sailors.

-- B. Find the average age of sailors who are of voting age for each rating level that has at least two such sailors.

-- C. Find those ratings for which the average age of sailors is the minimum over all ratings.

-- D. For each red boat, find the number of reservations for this boat.


------------------------------------------------------------
-- Ex 8. We want to see monthly trend of the reservation between August and December. 
-- You can assume that there are data from several years.
-- Create a table that has August, September, October, November and December.
-- Rows should be the number of reservation made.
-- If there is no reservation record, it should be 0.
------------------------------------------------------------


------------------------------------------------------------
-- Ex 9.  We want to see monthly trend of the reservation between August and December per year. 
-- You can assume that there are data from several years.
-- Create a table that has August, September, October, November and December.
-- Rows should be the number of reservation made of each year, where the first column is year.
-- If there is no reservation record, it should be 0.
------------------------------------------------------------


------------------------------------------------------------
-- Ex 10.
------------------------------------------------------------
-- A. For each red boat, find the number of reservations for this boat.

-- B. For each sailor id, find the number of reservations.

-- C. Find the possible sailor id and boat id combinations.

-- D. Find all possible sailor id and boat id combinations and the reserved dates. 
----- (If the sailor never reserved the boat, its date is NULL)


------------------------------------------------------------
-- Ex 11.
------------------------------------------------------------
-- A. Find the most common color of boat reserved for each sailor's name order by sid.
-- (If a sailor never reserved a boat, the color and max column should be NULL.)

-- B. For each boat id, calculate the cumulative number of reservations.


------------------------------------------------------------
-- Ex 12. We are interested in how many unique sailors reserved a boat each year along with how many reservation was made quarterly.
-- The output should have cohort(1st day of the year), the number of unique sailors, reservation made between Jan-Mar, Apr-Jun, Jul-Sep and Oct-Dec.
------------------------------------------------------------
