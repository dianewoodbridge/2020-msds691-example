--https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Procedural.Importing.html#USER_PostgreSQL.S3Import
CREATE EXTENSION aws_s3 CASCADE;

DROP TABLE IF EXISTS employees;

CREATE TABLE employees
(
	eid INTEGER CHECK (eid > 0),
	name VARCHAR(20) NOT NULL,
	title VARCHAR(10) NOT NULL,
	ssn INTEGER DEFAULT NULL,
	PRIMARY KEY (eid),
	UNIQUE (ssn)
);

--https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Procedural.Importing.html
SELECT aws_commons.create_s3_uri(
   'usfca-msds694',
   'nyt_bestsellers.json',
   'us-west-2'
) AS s3_uri 


--https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Procedural.Importing.html#USER_PostgreSQL.S3Import.FileFormats
SELECT aws_s3.table_import_from_s3(
   'employees', 'eid,name,title, ssn', '(FORMAT csv, HEADER true)',
   aws_commons.create_s3_uri('msds691', 'employees.csv','us-west-2')
);


