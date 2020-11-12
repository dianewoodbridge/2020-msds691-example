SHOW data_directory;

-------------------------------------------------------------------------
-- Ex 1. Create mta_no_index table using NY_MTA.csv without any index.
-- How long does it take to insert data?
-------------------------------------------------------------------------
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

--
SELECT hash_numeric(1),hash_numeric(2), hash_numeric(3);
SELECT hashtext('diane'), hashtext('yannet'), hashtext('terence');

-------------------------------------------------------------------------
--EX 2 Create mta_hash table using NY_MTA.csv with plaza_id hash-indexed.
--How long does it take to insert data?
-------------------------------------------------------------------------
DROP TABLE IF EXISTS mta_hash;

CREATE TABLE mta_hash (
	plaza_id INTEGER,
	date DATE,
	hr INTEGER,
	direction VARCHAR(1),
	vehicle_ez INTEGER,
	vehicle_cash INTEGER
);

CREATE INDEX plaza_id_hash ON mta_hash USING hash (plaza_id);

COPY mta_hash FROM '/Users/dwoodbridge/Class/2020_MSDS691/Data/NY_MTA.csv' CSV HEADER;

-------------------------------------------------------------------------
--- EX 3 Create mta_btree table using NY_MTA.csv with plaza_id b-tree indexed.
-- How long does it take to insert data?
-- Make sure to cluster the table using plaza_id.
-------------------------------------------------------------------------
DROP TABLE IF EXISTS mta_btree;

CREATE TABLE mta_btree (
	plaza_id INTEGER,
	date DATE,
	hr INTEGER,
	direction VARCHAR(1),
	vehicle_ez INTEGER,
	vehicle_cash INTEGER
);

CREATE INDEX plaza_id_btree ON mta_btree USING btree (plaza_id);
COPY mta_btree FROM '/Users/dwoodbridge/Class/2020_MSDS691/Data/NY_MTA.csv' CSV HEADER;

CLUSTER mta_btree USING plaza_id_btree;
-------------------------------------------------------------------------
--EX 4 Analyze the following in the mta_no_index table.
--Scan
--Equality Selection - plaza_id is 1
--Range Selection - plaza_id is great than 10
--Insert  - (101, '2020-09-22', 23, 'I', 415, 422)
--Delete - the inserted row
-------------------------------------------------------------------------
EXPLAIN ANALYZE VERBOSE SELECT * FROM mta_no_index;
EXPLAIN ANALYZE VERBOSE SELECT * FROM mta_no_index WHERE plaza_id = 1;
EXPLAIN ANALYZE VERBOSE SELECT * FROM mta_no_index WHERE plaza_id > 10;
EXPLAIN ANALYZE VERBOSE INSERT INTO mta_no_index VALUES (101, '2020-09-22', 23, 'I', 415, 422 );
EXPLAIN ANALYZE VERBOSE DELETE FROM mta_no_index WHERE plaza_id = 101 AND date = '2020-09-22' 
						AND hr=23 AND direction  ='I' AND vehicles_EZ = 415 AND vehicles_CASH = 422;

-------------------------------------------------------------------------
--EX 5 Analyze the following in the mta_hash table.
--Scan
--Equality Selection - plaza_id is 1
--Range Selection - plaza_id is great than 10
--Insert  - (101, '2020-09-22', 23, 'I', 415, 422)
--Delete - the inserted row
-------------------------------------------------------------------------
EXPLAIN ANALYZE VERBOSE SELECT * FROM mta_hash;
EXPLAIN ANALYZE VERBOSE SELECT * FROM mta_hash WHERE plaza_id = 1;
EXPLAIN ANALYZE VERBOSE SELECT * FROM mta_hash WHERE plaza_id > 10;
EXPLAIN ANALYZE VERBOSE INSERT INTO mta_hash VALUES (101, '2020-09-22', 23, 'I', 415, 422 );
EXPLAIN ANALYZE VERBOSE DELETE FROM mta_hash WHERE plaza_id = 101 AND date = '2020-09-22' 
						AND hr=23 AND direction  ='I' AND vehicles_EZ = 415 AND vehicles_CASH = 422;

-------------------------------------------------------------------------
--EX 6 Analyze the following in the mta_btree table.
--Scan
--Equality Selection - plaza_id is 1
--Range Selection - plaza_id is great than 10
--Insert  - (101, '2020-09-22', 23, 'I', 415, 422)
--Delete - the inserted row
-------------------------------------------------------------------------
EXPLAIN ANALYZE VERBOSE SELECT * FROM mta_btree;
EXPLAIN ANALYZE VERBOSE SELECT * FROM mta_btree WHERE plaza_id = 1;
EXPLAIN ANALYZE VERBOSE SELECT * FROM mta_btree WHERE plaza_id > 10;
EXPLAIN ANALYZE VERBOSE INSERT INTO mta_btree VALUES (101, '2020-09-22', 23, 'I', 415, 422 );
EXPLAIN ANALYZE VERBOSE DELETE FROM mta_btree WHERE plaza_id = 101 AND date = '2020-09-22' 
						AND hr=23 AND direction  ='I' AND vehicles_EZ = 415 AND vehicles_CASH = 422;

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
