-------------------------------------------------------------------------
-- Ex 1. Create mta_no_index table using NY_MTA.csv without any index.
-- How long does it take to insert data?
-------------------------------------------------------------------------

-- Hash functions

-------------------------------------------------------------------------
--EX 2 Create mta_hash table using NY_MTA.csv with plaza_id hash-indexed.
--How long does it take to insert data?
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--- EX 3 Create mta_btree table using NY_MTA.csv with plaza_id b-tree indexed.
-- How long does it take to insert data?
-- Make sure to cluster the table using plaza_id.
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--EX 4 Analyze the following in the mta_no_index table.
--Scan
--Equality Selection - plaza_id is 1
--Range Selection - plaza_id is great than 10
--Insert  - (101, '2020-09-22', 23, 'I', 415, 422)
--Delete - the inserted row
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--EX 5 Analyze the following in the mta_hash table.
--Scan
--Equality Selection - plaza_id is 1
--Range Selection - plaza_id is great than 10
--Insert  - (101, '2020-09-22', 23, 'I', 415, 422)
--Delete - the inserted row
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--EX 6 Analyze the following in the mta_btree table.
--Scan
--Equality Selection - plaza_id is 1
--Range Selection - plaza_id is great than 10
--Insert  - (101, '2020-09-22', 23, 'I', 415, 422)
--Delete - the inserted row
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- Ex 7 Which indexing algorithm and fields should be used, 
--      when the following queries happen often?
-------------------------------------------------------------------------
--a)
EXPLAIN ANALYZE VERBOSE
SELECT COUNT(*)
FROM mta_btree
WHERE hr = 23;

CREATE INDEX hr_btree ON mta_btree USING btree (hr);

EXPLAIN ANALYZE VERBOSE
SELECT COUNT(*)
FROM mta_btree
WHERE hr = 23;

DROP INDEX hr_btree;

--b
EXPLAIN ANALYZE VERBOSE
SELECT COUNT(*)
FROM mta_btree
WHERE hr > 17;

CREATE INDEX hr_btree ON mta_btree USING btree (hr);
CLUSTER mta_btree USING hr_btree;

EXPLAIN ANALYZE VERBOSE
SELECT COUNT(*)
FROM mta_btree
WHERE hr > 17;

DROP INDEX hr_btree;

--c
EXPLAIN ANALYZE VERBOSE
SELECT COUNT(*)
FROM mta_btree
WHERE hr > 17 and direction = 'I';

CREATE INDEX direction_hr_btree ON mta_btree USING btree (direction, hr);
CLUSTER mta_btree USING direction_hr_btree;

EXPLAIN ANALYZE VERBOSE
SELECT COUNT(*)
FROM mta_btree
WHERE hr > 17 and direction = 'I';

DROP INDEX direction_hr_btree;
--d
EXPLAIN ANALYZE VERBOSE
SELECT direction, hr, COUNT(*)
FROM mta_btree
WHERE hr > 17 
GROUP BY direction, hr;

CREATE INDEX hr_direction_btree ON mta_btree USING btree (hr, direction);
CLUSTER mta_btree USING hr_direction_btree;

EXPLAIN ANALYZE VERBOSE
SELECT direction, hr, COUNT(*)
FROM mta_btree
WHERE hr > 17 
GROUP BY direction, hr;

DROP INDEX hr_direction_btree;
