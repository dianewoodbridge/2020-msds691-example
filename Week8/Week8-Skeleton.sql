SELECT *
FROM information_schema.columns
WHERE table_name = 'epa_air_quality';

-- Ex 2. Create epa_air_quality table and make sure it’s a 1NF.


-- Ex 4. Normalize epa_air_quality in 2NF.
-- Think about the functional dependencies and candidate keys.
-- Check the functional dependencies.


-- Ex 5. Create a view called epa_air_quality_2nf_joined to return the output same as the original data using the normalized tables.


-- Ex 6. Create the insert_epa_data() function to insert a row in a format of (date, source, poc, daily_mean_pm10_conentration, units, daily_aqi_value, site_name, daily_obs_count, percent_complete, aqs_parameter_code, aqs_parameter_desc, cbsa_code, cbsa_name, state_code, state, county_code, county, site_latitude, site_longitude) to the normalized tables (2NF).


-- Ex. 8 Normalize epa_site_location into 3NF.


-- Ex 9. Create a view called epa_air_quality_3nf_joined to return the output same as the original data using the normalized tables.


-- Ex 10. Create the insert_epa_data() function to insert a row in a format of (date, source, poc, daily_mean_pm10_conentration, units, daily_aqi_value, site_name, daily_obs_count, percent_complete, aqs_parameter_code, aqs_parameter_desc, cbsa_code, cbsa_name, state_code, state, county_code, county, site_latitude, site_longitude) to the normalized tables (3NF).

