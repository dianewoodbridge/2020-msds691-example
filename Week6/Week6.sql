DROP TABLE IF EXISTS mta_btree;

CREATE TABLE mta_btree (
plaza_id int
, date date
, hr int
, direction varchar(10)
, vehicles_EZ int
, vehicles_CASH int
);

CREATE INDEX plaza_id_btree ON mta_btree USING btree (plaza_id);

DELETE FROM mta_btree;
COPY mta_btree FROM '/Users/dwoodbridge/Class/2020_MSDS691/Data/NY_MTA.csv' CSV HEADER;


--EX 1-3. Atomicity
--Ex 1. Abort
--Write a transaction for mta_btree that
--A.Return the number of records for plaza_id is 1.
--B.Wait for 10 seconds 
----SELECT pg_sleep(seconds)
--C.Update plaza_id to 2 when plaza_id = 1, direction = 'I' and the year value in date is 2010 the mta_btree  --table.
--D.Return the number of records for plaza_id is 1.
--E.What happens if you rollback?
--F.Return the number of records for plaza_id is 1.
--Are outputs of A, D and F are the same?

BEGIN;
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; -- 130560
SELECT pg_sleep(10);
UPDATE mta_btree SET plaza_id = 2 WHERE plaza_id = 1 AND direction = 'I' AND EXTRACT(YEAR FROM date) = 2010; 
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; -- 121800
ROLLBACK;
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; -- 130560

--Ex 2. Abort
--Write a transaction for mta_btree that
--A.Return the number of records for plaza_id is 1.
--B.Wait for 10 seconds 
----SELECT pg_sleep(seconds)
--C.Update plaza_id to 2 when plaza_id = 1, direction = 'I' and the year value in date is 2010 the mta_btree  table.
--D.Return the number of records for plaza_id is 1.
--E.Update plaza_id to 3/0 when plaza_id = 1, direction = 'I' and the year value in date is 2011 the mta_btree  table.
--F.Return the number of records for plaza_id is 1.
--G.What happens if you commit?
--H.Return the number of records for plaza_id is 1.
--Are outputs of A, D, F and H are the same?

BEGIN;
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; --130560
SELECT pg_sleep(10);
UPDATE mta_btree SET plaza_id = 2 WHERE plaza_id = 1 AND direction = 'I' AND EXTRACT(YEAR FROM date) = 2010; 
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; --121800
UPDATE mta_btree SET plaza_id = 3/0 WHERE plaza_id = 1 AND direction = 'I' AND EXTRACT(YEAR FROM date) = 2011; --Error
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; --Error
COMMIT; -- But it rolls back
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; --130560

--Ex 3. COMMIT
--Write a transaction for mta_btree that
--A.Return the number of records for plaza_id is 1.
--B.Wait for 10 seconds 
----SELECT pg_sleep(seconds)
--C.Update plaza_id to 2 when plaza_id = 1, direction = 'I' and the year value in date is 2010 the mta_btree  table.
--D.Return the number of records for plaza_id is 1.
--E.Update plaza_id to 3 when plaza_id = 1, direction = 'I' and the year value in date is 2011 the mta_btree  table.
--F.Return the number of records for plaza_id is 1.
--G.What happens if you commit?
--H.Return the number of records for plaza_id is 1.
--Are outputs of A, D, F and H are the same?

BEGIN;
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; --130560
SELECT pg_sleep(10);
UPDATE mta_btree SET plaza_id = 2 WHERE plaza_id = 1 AND direction = 'I' AND EXTRACT(YEAR FROM date) = 2010; 
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; --121800
UPDATE mta_btree SET plaza_id = 3 WHERE plaza_id = 1 AND direction = 'I' AND EXTRACT(YEAR FROM date) = 2011; 
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; --113040
COMMIT; 
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; --113040


--Ex 4.Write and run the queries in two separate query tools.
----Can you run those two queries at the same time?

--Query tool 1 (start first)
--Write a transaction for mta_btree that
--A.Return the number of records for plaza_id is 1.
--B.Wait for 10 seconds 
----SELECT pg_sleep(seconds)
--C.Update plaza_id to 2 when plaza_id = 1, direction = 'I' and the year value in date is 2010 the mta_btree  table.
--D.Return the number of records for plaza_id is 1.
--E.commit
--F.Return the number of records for plaza_id is 1.

BEGIN;
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; -- 113040
SELECT pg_sleep(10);
UPDATE mta_btree SET plaza_id = 2 WHERE plaza_id = 1 AND direction = 'I' AND EXTRACT(YEAR FROM date) = 2010; 
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; -- 113040
COMMIT;
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; -- 113040

--Query tool 2 (start right after the first one)
--Write a transaction for mta_btree that
--A.Return the number of records for plaza_id is 1.
----Wait for 10 seconds 
--B.SELECT pg_sleep(seconds)
--C.Update plaza_id to 1 when plaza_id = 2, direction = 'I' and the year value in date is 2010 the mta_btree  table.
--D.Return the number of records for plaza_id is 1.
--E.commit
--F.Return the number of records for plaza_id is 1.

BEGIN;
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; -- 113040
SELECT pg_sleep(10);
UPDATE mta_btree SET plaza_id = 1 WHERE plaza_id = 2 AND direction = 'I' AND EXTRACT(YEAR FROM date) = 2010; 
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; -- 130560
COMMIT;
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; -- 130560


--Ex 5. Unrepeatable Reads (RW Conflict) with Ex 4-1. 
DELETE FROM mta_btree;
COPY mta_btree FROM '/Users/dwoodbridge/Class/2020_MSDS691/Data/NY_MTA.csv' CSV HEADER;

--A. Create a transaction that 
--Counts the number of rows for plaza_id = 1.
--Takes 30 seconds break 
--Counts the number of rows for plaza_id = 1.
--B.Run with the transaction above with Example 4 - 1.
--C. Try with BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED and BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ
--Is the first reading same as the second reading in A?

--READ COMMITTED
--Query tool 1 (start first)
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; --130560
SELECT pg_sleep(30);
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; --121800
COMMIT;

--Query tool 2 (start right after the first one)
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; -- 130560
SELECT pg_sleep(10);
UPDATE mta_btree SET plaza_id = 2 WHERE plaza_id = 1 AND direction = 'I' AND EXTRACT(YEAR FROM date) = 2010; 
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; -- 121800
COMMIT;

--REPEATABLE READ
--Query tool 1 (start first)
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; --130560
SELECT pg_sleep(30);
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; --121800
COMMIT;

--Query tool 2 (start right after the first one)
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; -- 130560
SELECT pg_sleep(10);
UPDATE mta_btree SET plaza_id = 2 WHERE plaza_id = 1 AND direction = 'I' AND EXTRACT(YEAR FROM date) = 2010; 
SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; -- 121800
COMMIT;

SELECT COUNT(*) FROM mta_btree WHERE plaza_id = 1; -- 121800

--Ex 6.  Phantom Read
DELETE FROM mta_btree;
COPY mta_btree FROM '/Users/dwoodbridge/Class/2020_MSDS691/Data/NY_MTA.csv' CSV HEADER;

--A. Create a transaction that 
--Return the minimum plaza_id. —1
--Takes 30 seconds break 
--Return the maximum plaza_id. —4

--B.Create a transaction that 
--Insert the row, (31, '2020-11-14', 0, 'O', 115, 114). —2
--Delete all the rows where plaza_id is 1. —3

--Try with BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED and BEGIN TRANSACTION ISOLATION SERIALIZABLE
--Is B same as the second reading in A?

--Expected Output (1,30) or (2, 31)
--READ COMMITTED
--Query tool 1 (start first)
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT MIN(plaza_id) FROM mta_btree; --1 (1)
SELECT pg_sleep(30);
SELECT MAX(plaza_id) FROM mta_btree; -- 8 (31)
COMMIT; -- 9
--Query tool 2 (start right after the first one)
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED; --2
SELECT MAX(plaza_id), MIN(plaza_id) FROM mta_btree; --3
INSERT INTO mta_btree VALUES (31, '2020-11-14', 0, 'O', 115, 114); --4
DELETE FROM mta_btree WHERE plaza_id = 1; --5
SELECT MAX(plaza_id), MIN(plaza_id) FROM mta_btree; --6 (31,2)
COMMIT; --7

DELETE FROM mta_btree;
COPY mta_btree FROM '/Users/dwoodbridge/Class/2020_MSDS691/Data/NY_MTA.csv' CSV HEADER;

--SERIALIZABLE
--Query tool 1 (start first)
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT MIN(plaza_id) FROM mta_btree; --1 (1)
SELECT pg_sleep(30);
SELECT MAX(plaza_id) FROM mta_btree; -- 8 (could not serialize access due to read/write dependencies among transactions)
COMMIT; -- 9  ROLLBACK

--Query tool 2 (start right after the first one)
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT MAX(plaza_id), MIN(plaza_id) FROM mta_btree; --3
INSERT INTO mta_btree VALUES (31, '2020-11-14', 0, 'O', 115, 114); --4
DELETE FROM mta_btree WHERE plaza_id = 1; --5
SELECT MAX(plaza_id), MIN(plaza_id) FROM mta_btree; --6 (31,2)
COMMIT; --7


--Ex 7. Lost Update
--A. Create a transaction that —1
--Update all the plaza_id to 1.
--Takes 10 seconds break 

--B. Create a transaction that —2
--Update all the plaza_id to 2.
--Takes 10 seconds break 

--Try with BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED and BEGIN TRANSACTION ISOLATION SERIALIZABLE
--Is B same as the second reading in A?

SELECT plaza_id, COUNT(*) FROM mta_btree GROUP BY plaza_id;

--Query tool 1 (start first)
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED; 
UPDATE mta_btree SET plaza_id = 1;
SELECT pg_sleep(30);
COMMIT; 

--Query tool 2 (start after)
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
UPDATE mta_btree SET plaza_id = 2;
SELECT pg_sleep(30);
COMMIT;

SELECT plaza_id, COUNT(*) FROM mta_btree GROUP BY plaza_id; 


--Query tool 1 (start first)
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE; 
UPDATE mta_btree SET plaza_id = 1;
SELECT pg_sleep(30);
COMMIT; 

--Query tool 2 (start after)
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE; 
UPDATE mta_btree SET plaza_id = 2;
SELECT pg_sleep(30);
COMMIT; --ERROR:  could not serialize access due to concurrent update
