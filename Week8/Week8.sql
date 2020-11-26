SELECT *
FROM information_schema.columns
WHERE table_name = 'epa_air_quality';

--Ex 2. Create epa_air_quality table and make sure it’s a 1NF.
DROP TABLE IF EXISTS epa_air_quality CASCADE;

CREATE TABLE epa_air_quality
(
	date	DATE,
	source	VARCHAR(3),
	site_id	INTEGER,
	poc	INTEGER, 
	daily_mean_pm10_conentration	INTEGER,
	units	VARCHAR(10),
	daily_aqi_value	 INTEGER,
	site_name	VARCHAR(50),
	daily_obs_count	INTEGER,
	percent_complete	REAL,
	aqs_parameter_code	INTEGER, 
	aqs_parameter_desc	VARCHAR(50),
	cbsa_code	VARCHAR(10),
	cbsa_name	VARCHAR(50),
	state_code	INTEGER,
	state	VARCHAR(30),
	county_code	INTEGER,
	county	VARCHAR(50),
	site_latitude	REAL,
	site_longitude REAL
);

COPY epa_air_quality FROM '/Users/dwoodbridge/Class/2020_MSDS691/Data/epa_air_quality.csv' CSV HEADER;
SELECT COUNT(*) FROM epa_air_quality WHERE site_id IS NULL; --15894
SELECT * FROM epa_air_quality;
SELECT DISTINCT * FROM epa_air_quality ORDER BY date, site_id;
SELECT DISTINCT * FROM epa_air_quality ORDER BY date, site_id, poc;

ALTER TABLE epa_air_quality ADD PRIMARY KEY (date, site_id, poc);

-- Ex 4. Normalize epa_air_quality in 2NF.
-- Think about the functional dependencies and candidate keys.
-- Check the functional dependencies.
SELECT DISTINCT source, units, aqs_parameter_code, aqs_parameter_desc
FROM epa_air_quality;

SELECT DISTINCT  state, cbsa_name, county, site_name, site_id
FROM epa_air_quality
ORDER BY state, cbsa_name, county, site_name, site_id;

--Info table which is global for all the rows and not dependent to any candidate keys.
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
DROP TABLE IF EXISTS epa_pm_10_info;
CREATE TABLE epa_pm_10_info AS
(
	SELECT DISTINCT aqs_parameter_code, aqs_parameter_desc, source, units
	FROM epa_air_quality
);
ALTER TABLE epa_pm_10_info ADD PRIMARY KEY (aqs_parameter_code);
COMMIT;

SELECT * FROM epa_pm_10_info;

--Location-related table
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
DROP TABLE IF EXISTS epa_site_location CASCADE;
CREATE TABLE epa_site_location AS
(
	SELECT DISTINCT site_id, site_name, site_latitude, site_longitude, county_code, county, cbsa_code, cbsa_name, state_code, state
	FROM epa_air_quality
);
ALTER TABLE epa_site_location ADD PRIMARY KEY (site_id);
ALTER TABLE epa_air_quality ADD CONSTRAINT epa_site_foreign_key FOREIGN KEY (site_id) REFERENCES epa_site_location(site_id) ON UPDATE CASCADE ON DELETE CASCADE;
COMMIT;

SELECT * FROM epa_site_location;

--Choose columns on the epa_air_quality that has candiate_keys and qualifying columns that are dependent on the entire candidate key.
ALTER TABLE epa_air_quality 
			DROP COLUMN site_name,
			DROP COLUMN site_latitude,
			DROP COLUMN site_longitude,
			DROP COLUMN county_code,
			DROP COLUMN county,
			DROP COLUMN cbsa_code,
			DROP COLUMN cbsa_name,
			DROP COLUMN state_code,
			DROP COLUMN state,
			DROP COLUMN aqs_parameter_code,
			DROP COLUMN aqs_parameter_desc,
			DROP COLUMN source,
			DROP COLUMN units;
			
SELECT * FROM epa_air_quality;
SELECT DISTINCT daily_obs_count, percent_complete FROM epa_air_quality;

-- Ex 5. Create a view called epa_air_quality_2nf_joined to return the output same as the original data using the normalized tables.
BEGIN;
DROP VIEW IF EXISTS epa_air_quality_2nf_joined;
CREATE VIEW epa_air_quality_2nf_joined AS
SELECT date 
,source
,epa_site_location.site_id
,poc
,daily_mean_pm10_conentration
,units
,daily_aqi_value
,epa_site_location.site_name	
,daily_obs_count
,percent_complete
,aqs_parameter_code
,aqs_parameter_desc
,epa_site_location.cbsa_code
,epa_site_location.cbsa_name
,epa_site_location.state_code
,epa_site_location.state
,epa_site_location.county_code
,epa_site_location.county
,epa_site_location.site_latitude	
,epa_site_location.site_longitude 
FROM epa_air_quality
JOIN epa_site_location
ON epa_air_quality.site_id = epa_site_location.site_id
CROSS JOIN epa_pm_10_info;
COMMIT;

SELECT * FROM epa_air_quality_2nf_joined;

--Ex 5. Create the insert_epa_data() function to insert a row in a format of (date, source, poc, daily_mean_pm10_conentration, units, daily_aqi_value, site_name, daily_obs_count, percent_complete, aqs_parameter_code, aqs_parameter_desc, cbsa_code, cbsa_name, state_code, state, county_code, county, site_latitude, site_longitude) to the normalized tables (2NF).
SELECT MAX(date) FROM epa_air_quality;

DROP FUNCTION IF EXISTS insert_epa_data;
CREATE FUNCTION insert_epa_data(date_val DATE,
	source_val	VARCHAR(3),
	site_id_val	INTEGER,
	poc_val	INTEGER, 
	daily_mean_pm10_conentration_val	INTEGER,
	units_val	VARCHAR(10),
	daily_aqi_value_val	 INTEGER,
	site_name_val	VARCHAR(50),
	daily_obs_count_val	INTEGER,
	percent_complete_val	REAL,
	aqs_parameter_code_val	INTEGER, 
	aqs_parameter_desc_val	VARCHAR(50),
	cbsa_code_val	VARCHAR(10),
	cbsa_name_val	VARCHAR(50),
	state_code_val	INTEGER,
	state_val	VARCHAR(30),
	county_code_val	INTEGER,
	county_val	VARCHAR(50),
	site_latitude_val	REAL,
	site_longitude_val REAL)
RETURNS VOID AS
$$

INSERT INTO epa_pm_10_info VALUES (aqs_parameter_code_val, aqs_parameter_desc_val, source_val, units_val)
ON CONFLICT DO NOTHING;

INSERT INTO epa_site_location VALUES (site_id_val, site_name_val, site_latitude_val, site_longitude_val, county_code_val, county_val, cbsa_code_val, cbsa_name_val, state_code_val, state_val)
ON CONFLICT DO NOTHING;

INSERT INTO epa_air_quality VALUES (date_val, site_id_val, poc_val, daily_mean_pm10_conentration_val, daily_aqi_value_val, daily_obs_count_val, percent_complete_val) ON CONFLICT DO NOTHING;

$$
LANGUAGE SQL;

SELECT * FROM insert_epa_data('2020-11-16', 'AQS', 60070008,3,27,'ug/m3 SC',25,'Chico-East Avenue',1,100,81102,'PM10 Total 0-10um STP','17020','Chico, CA',6,'California',7,'Butte',39.76168, -121.84047);

SELECT MAX(date) FROM epa_air_quality;

--Ex. 8 Normalize epa_site_location into 3NF.
--epa_pm_10_info : Already 3NF
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'epa_pm_10_info';

SELECT * FROM epa_pm_10_info;

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'epa_air_quality';

SELECT DISTINCT daily_obs_count, percent_complete FROM epa_air_quality;

--epa_site_location
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'epa_site_location';

SELECT site_id, COUNT(*) FROM epa_site_location
GROUP BY site_id;

SELECT * FROM epa_site_location
ORDER BY state_code, cbsa_code, county_code, site_id;

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
DROP TABLE IF EXISTS county, site_county;
CREATE TABLE county AS
( 
	SELECT DISTINCT county_code, county
	FROM epa_site_location
);
CREATE TABLE site_county AS
(
	SELECT DISTINCT site_id, county_code
	FROM epa_site_location
);
ALTER TABLE county ADD PRIMARY KEY (county_code);
ALTER TABLE site_county ADD PRIMARY KEY (site_id);
ALTER TABLE site_county ADD CONSTRAINT site_id_foreign_key FOREIGN KEY (site_id) REFERENCES epa_site_location(site_id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE site_county ADD CONSTRAINT county_code_foreign_key FOREIGN KEY (county_code) REFERENCES county(county_code) ON UPDATE CASCADE ON DELETE CASCADE;
COMMIT;

SELECT * FROM county;
SELECT * FROM site_county;

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
DROP TABLE IF EXISTS cbsa, county_cbsa;
CREATE TABLE cbsa AS(
	SELECT DISTINCT cbsa_code, cbsa_name
	FROM epa_site_location
);
CREATE TABLE county_cbsa AS (
	SELECT DISTINCT county_code, cbsa_code
	FROM epa_site_location
);

ALTER TABLE cbsa ADD PRIMARY KEY (cbsa_code);

ALTER TABLE county_cbsa ADD PRIMARY KEY (county_code);
ALTER TABLE county_cbsa ADD CONSTRAINT county_code_foreign_key FOREIGN KEY (county_code) REFERENCES county(county_code) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE county_cbsa ADD CONSTRAINT cbsa_code_foreign_key FOREIGN KEY (cbsa_code) REFERENCES cbsa(cbsa_code) ON UPDATE CASCADE ON DELETE CASCADE;
COMMIT;

SELECT * FROM cbsa;
SELECT * FROM county_cbsa;

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
DROP TABLE IF EXISTS state, cbsa_state;
CREATE TABLE state AS(
	SELECT DISTINCT state_code, state
	FROM epa_site_location
);
CREATE TABLE cbsa_state AS (
	SELECT DISTINCT cbsa_code, state_code
	FROM epa_site_location
);

ALTER TABLE state ADD PRIMARY KEY (state_code);

ALTER TABLE cbsa_state ADD PRIMARY KEY (cbsa_code);
ALTER TABLE cbsa_state ADD CONSTRAINT cbsa_code_foreign_key FOREIGN KEY (cbsa_code) REFERENCES cbsa(cbsa_code) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE cbsa_state ADD CONSTRAINT state_code_foreign_key FOREIGN KEY (state_code) REFERENCES state(state_code) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE epa_site_location 
DROP COLUMN county_code CASCADE, 
DROP COLUMN county CASCADE,
DROP COLUMN cbsa_code CASCADE,
DROP COLUMN cbsa_name CASCADE,
DROP COLUMN state_code CASCADE,
DROP COLUMN state CASCADE;
COMMIT;

--Ex 9. Create a view called epa_air_quality_3nf_joined to return the output same as the original data using the normalized tables.
BEGIN;
DROP VIEW IF EXISTS epa_air_quality_3nf_joined;
CREATE VIEW epa_air_quality_3nf_joined AS
SELECT date 
,source
,epa_site_location.site_id
,poc
,daily_mean_pm10_conentration
,units
,daily_aqi_value
,epa_site_location.site_name	
,daily_obs_count
,percent_complete
,aqs_parameter_code
,aqs_parameter_desc
,cbsa.cbsa_code
,cbsa.cbsa_name
,state.state_code
,state.state
,county.county_code
,county.county
,epa_site_location.site_latitude	
,epa_site_location.site_longitude 
FROM epa_air_quality
JOIN epa_site_location
ON epa_air_quality.site_id = epa_site_location.site_id
JOIN site_county
ON epa_site_location.site_id = site_county.site_id
JOIN county
ON county.county_code = site_county.county_code
JOIN county_cbsa
ON county.county_code = county_cbsa.county_code
JOIN cbsa
ON county_cbsa.cbsa_code = cbsa.cbsa_code
JOIN cbsa_state
ON cbsa.cbsa_code = cbsa_state.cbsa_code
JOIN state
ON cbsa_state.state_code = state.state_code
CROSS JOIN epa_pm_10_info;
COMMIT;

SELECT * FROM epa_air_quality_3nf_joined;

--Ex 10. Create the insert_epa_data() function to insert a row in a format of (date, source, poc, daily_mean_pm10_conentration, units, daily_aqi_value, site_name, daily_obs_count, percent_complete, aqs_parameter_code, aqs_parameter_desc, cbsa_code, cbsa_name, state_code, state, county_code, county, site_latitude, site_longitude) to the normalized tables (3NF).
DROP FUNCTION IF EXISTS insert_epa_data;
CREATE FUNCTION insert_epa_data(date_val DATE,
	source_val	VARCHAR(3),
	site_id_val	INTEGER,
	poc_val	INTEGER, 
	daily_mean_pm10_conentration_val	INTEGER,
	units_val	VARCHAR(10),
	daily_aqi_value_val	 INTEGER,
	site_name_val	VARCHAR(50),
	daily_obs_count_val	INTEGER,
	percent_complete_val	REAL,
	aqs_parameter_code_val	INTEGER, 
	aqs_parameter_desc_val	VARCHAR(50),
	cbsa_code_val	VARCHAR(10),
	cbsa_name_val	VARCHAR(50),
	state_code_val	INTEGER,
	state_val	VARCHAR(30),
	county_code_val	INTEGER,
	county_val	VARCHAR(50),
	site_latitude_val	REAL,
	site_longitude_val REAL)
RETURNS VOID AS
$$

INSERT INTO epa_pm_10_info VALUES (aqs_parameter_code_val, aqs_parameter_desc_val, source_val, units_val)
ON CONFLICT DO NOTHING;
INSERT INTO epa_site_location VALUES (site_id_val, site_name_val, site_latitude_val, site_longitude_val)
ON CONFLICT DO NOTHING;
INSERT INTO county VALUES(county_code_val, county_val) ON CONFLICT DO NOTHING;
INSERT INTO site_county VALUES(site_id_val, county_code_val) ON CONFLICT DO NOTHING;
INSERT INTO cbsa VALUES (cbsa_code_val, cbsa_name_val) ON CONFLICT DO NOTHING;
INSERT INTO county_cbsa VALUES (county_code_val, cbsa_code_val) ON CONFLICT DO NOTHING;
INSERT INTO state VALUES (state_code_val, state_val) ON CONFLICT DO NOTHING;
INSERT INTO cbsa_state VALUES (cbsa_code_val, state_code_val) ON CONFLICT DO NOTHING;

INSERT INTO epa_air_quality VALUES (date_val, site_id_val, poc_val, daily_mean_pm10_conentration_val, daily_aqi_value_val, daily_obs_count_val, percent_complete_val) ON CONFLICT DO NOTHING;

$$
LANGUAGE SQL;

SELECT * FROM insert_epa_data('2020-11-17', 'AQS', 60070008,3,27,'ug/m3 SC',25,'Chico-East Avenue',1,100,81102,'PM10 Total 0-10um STP','17020','Chico, CA',6,'California',7,'Butte',39.76168, -121.84047);



