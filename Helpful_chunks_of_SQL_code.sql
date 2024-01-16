

--------------------------------------------- String manipulation ---------------------------------------------
SELECT
  name,
  city
FROM
  `runtimes-394701.customer_data.customer_address`


INSERT INTO `runtimes-394701.customer_data.customer_address`
  (customer_id, address, city, state, zipcode, country)
VALUES
  (2645, '333 SQL Road', 'Jackson', 'MI', 49202, 'US')


UPDATE `runtimes-394701.customer_data.customer_address`
SET address = '123 New Address'
WHERE customer_id = 2645


SELECT
  DISTINCT customer_id
FROM
  `runtimes-394701.customer_data.customer_address`


SELECT
  country
FROM
  `runtimes-394701.customer_data.customer_address`
WHERE
  LENGTH(country) > 2


SELECT
  DISTINCT customer_id
FROM
  `runtimes-394701.customer_data.customer_address`
WHERE
  SUBSTR(country,1,2) = 'US'

SELECT
  state
FROM
  `runtimes-394701.customer_data.customer_address`
WHERE
  LENGTH(state) > 2


SELECT
  DISTINCT customer_id
FROM
  `runtimes-394701.customer_data.customer_address`
WHERE
  TRIM(state) = 'OH'


---------------------------------------------Update--------------------------------------------

SELECT  
  DISTINCT fuel_type
FROM
  `runtimes-394701.cars.car_info` 
LIMIT 1000

------------
SELECT
  MIN(length) AS min_length,
  MAX(length) AS max_length
FROM
  `runtimes-394701.cars.car_info`

------------
SELECT
  *
FROM
  `runtimes-394701.cars.car_info`
WHERE
  num_of_doors IS NULL

------------
UPDATE
  `runtimes-394701.cars.car_info`
SET
  num_of_doors = "four"
WHERE
  make = 'dodge'
  AND fuel_type = "gas"
  AND body_style ="sedan"

------------
UPDATE
  `runtimes-394701.cars.car_info`
SET
  num_of_doors = "four"
WHERE
  make = 'mazda'
  AND fuel_type = "diesel"
  AND body_style ="sedan"
------------
SELECT
  DISTINCT num_of_cylinders
FROM
  `runtimes-394701.cars.car_info`
------------
UPDATE
  `runtimes-394701.cars.car_info`
SET
  num_of_cylinders = "two"
WHERE
  num_of_cylinders = "tow"

------------
SELECT
  stn,
  date,
-- Use the IF function to replace 9999.9 values, which the dataset description explains is the default value when the temperature is missing, with NULLs instead.
  IF(
     temp=9999.9,
     NULL,
     temp) AS temperature,
-- Use the IF function to replace 999.9 values, which the dataset description explains is the default value when wind speed is missing, with NULLs instead.
  IF(
     wdsp="999.9",
     NULL,
     CAST(wdsp AS Float64)) AS wind_speed,
-- Use the IF function to replace 99.99 values, which the dataset description explains is the default value when precipitation is missing, with NULLs instead.
  IF(
     prcp=99.99,
     0,
     prcp) AS precipitation
FROM
  `bigquery-public-data.noaa_gsod.gsod2020`
WHERE
  stn="725030" -- La Guardia
  OR stn="744860" -- JFK
ORDER BY
  date DESC,
  stn ASC

--------------------------------------------- Count and Count Distinct---------------------------------------------
SELECT
  warehouse.state,
  COUNT  ( warehouse.state) as num_states
FROM
  `runtimes-394701.warehouse_orders.orders` AS orders
JOIN
  `runtimes-394701.warehouse_orders.warehouse` AS warehouse ON orders.warehouse_id = warehouse.warehouse_id
GROUP BY
  warehouse.state
-------------
SELECT
  warehouse.state,
  COUNT  (DISTINCT warehouse.state) as num_states
FROM
  `runtimes-394701.warehouse_orders.orders` AS orders
JOIN
  `runtimes-394701.warehouse_orders.warehouse` AS warehouse ON orders.warehouse_id = warehouse.warehouse_id
GROUP BY
  warehouse.state



--------------------------------------------- Calculations ----------------------------------------------


--the total number of bags of avocados sold on each day at each location
SELECT  
  Date, 
  region, 
  Small_Bags, 
  Large_Bags, 
  XLarge_Bags, 
  Total_Bags,
  Small_Bags + Large_Bags + XLarge_Bags AS Total_Bags_Calc
FROM 
  `runtimes-394701.avocado_data.avocado_prices` 


---What percent of the total bags were small bags
SELECT  
  Date, 
  region, 
  Small_Bags,  
  Total_Bags,
  (Small_Bags/Total_Bags)*100  AS Small_Percent
FROM 
  `runtimes-394701.avocado_data.avocado_prices` 
WHERE
  Total_Bags <> 0  --Can also use !=

SELECT*
FROM 
  (
    SELECT  
    Date, 
      region, 
      Small_Bags, 
      Large_Bags, 
      XLarge_Bags, 
      Total_Bags,
      Small_Bags + Large_Bags + XLarge_Bags AS Total_Bags_Calc
    FROM 
      `runtimes-394701.avocado_data.avocado_prices` 
  )
WHERE
  Total_Bags != Total_Bags_Calc  --Can also use !=

--Using city bike data 

SELECT  
  EXTRACT(YEAR FROM starttime) AS year,--Extract allows pull one part of a given data
  COUNT(*) AS number_of_rides
FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
GROUP BY
  year
ORDER BY --Order defaults to ascending order add DESC for descending
  year 

---Subway riders data
SELECT
  station_name, 
  ridership_2013, 
  ridership_2014, 
  ridership_2014 - ridership_2013 AS change_2014_raw
FROM `bigquery-public-data.new_york_subway.subway_ridership_2013_present` 

SELECT
  station_name,  
  ridership_2016,
  ridership_2017, 
  ridership_2018, 
  (ridership_2016 + ridership_2017 + ridership_2018)/3 AS avg
FROM `bigquery-public-data.new_york_subway.subway_ridership_2013_present` 


--------------------------------------------- Subquerries ---------------------------------------------

--Compare number of bikes available to the avg num available at all stations
SELECT
  station_id,
  num_bikes_available,
  (SELECT
    AVG(num_bikes_available)
  FROM
   `bigquery-public-data.new_york_citibike.citibike_stations`) AS avg_num_available
FROM
  `bigquery-public-data.new_york_citibike.citibike_stations`

--Could use a FROM statement to calculate the # of rides that have started at each station over time
SELECT
  id,
  name,
  number_of_rides AS number_of_rides_starting_station
FROM
  (
    SELECT
      start_station_id,
      COUNT(*) number_of_rides
    FROM
      bigquery-public-data.london_bicycles.cycle_hire
    GROUP BY
      start_station_id
  )
  AS station_num_trips
  INNER JOIN
  bigquery-public-data.london_bicycles.cycle_stations ON id = start_station_id
  ORDER BY
    number_of_rides DESC

--Use a WHERE statement 
-- To differentiate bn subscribers and one-time customers find a list of stations subscribers used
SELECT
  id,
  name
FROM
  bigquery-public-data.london_bicycles.cycle_stations
WHERE
  id IN
  (
    SELECT
      start_station_id
    FROM
      bigquery-public-data.london_bicycles.cycle_hire
    WHERE
      bike_model = "CLASSIC"
  )
---Not working for some reason

------USING Warehous data------

----What percetange of the orders are fulffiled by each warehouse?
SELECT
  warehouse.warehouse_id,
  CONCAT(warehouse.state, ': ', warehouse.warehouse_alias) AS warehouse_name,
  COUNT(orders.order_id) AS number_of_orders,
  (
    SELECT
      COUNT(*)
    FROM
      `runtimes-394701.warehouse_orders.orders`
  ) AS total_orders,
  CASE
    WHEN COUNT(orders.order_id)/ (SELECT COUNT(*) FROM `runtimes-394701.warehouse_orders.orders`) <= 0.20
    THEN "Fulffiled 0-20% of Orders"
    WHEN COUNT(orders.order_id)/ (SELECT COUNT(*) FROM `runtimes-394701.warehouse_orders.orders`) > 0.20
    AND COUNT(orders.order_id)/ (SELECT COUNT(*) FROM `runtimes-394701.warehouse_orders.orders`) <= 0.60
    THEN "Fulfilled 21-60% of Orders"
  ELSE "Fulfilled more than 60% of orders"
  END AS fulfilllment_summary
FROM 
  `runtimes-394701.warehouse_orders.warehouse`AS warehouse
LEFT JOIN 
  `runtimes-394701.warehouse_orders.orders`AS orders 
  ON orders.warehouse_id = warehouse.warehouse_id
GROUP BY
  warehouse.warehouse_id,
  warehouse_name
HAVING
  COUNT(orders.order_id) > 0



------------------------------------------ Joins  ---------------------------------------------

--INNER JOIN

SELECT
  employees.name AS employee_name, 
  employees.role AS employee_role, 
  departments.name AS department_name
FROM 
  employee_data.employees
INNER JOIN
  employee_data.departments ON
  employees.department_id = departments.department_id

-- LEFT JOIN
SELECT
  employees.name AS employee_name, 
  employees.role AS employee_role, 
  departments.name AS department_name
FROM 
  employee_data.employees
LEFT JOIN
  employee_data.departments ON
  employees.department_id = departments.department_id
  --Mary Martin is included in this but department name is null

--RIGHT JOIN
SELECT
  employees.name AS employee_name, 
  employees.role AS employee_role, 
  departments.name AS department_name
FROM 
  employee_data.employees
RIGHT JOIN
  employee_data.departments ON
  employees.department_id = departments.department_id
  --nulls for all the departments not included in the employees table 

--OUTER JOIN
SELECT
  employees.name AS employee_name, 
  employees.role AS employee_role, 
  departments.name AS department_name
FROM 
  employee_data.employees
FULL OUTER JOIN
  employee_data.departments ON
  employees.department_id = departments.department_id
  --Includes all the infor from both tables combo of LEFT and RIGHT


--------------Work with world bank education dataset-------------------

SELECT 
    `bigquery-public-data.world_bank_intl_education.international_education`.country_name, 
    `bigquery-public-data.world_bank_intl_education.country_summary`.country_code, 
    `bigquery-public-data.world_bank_intl_education.international_education`.value
FROM 
    `bigquery-public-data.world_bank_intl_education.international_education`
INNER JOIN 
    `bigquery-public-data.world_bank_intl_education.country_summary` 
ON `bigquery-public-data.world_bank_intl_education.country_summary`.country_code = `bigquery-public-data.world_bank_intl_education.international_education`.country_code

----using aliases

SELECT 
    edu.country_name,
    summary.country_code,
    edu.value
FROM 
    bigquery-public-data.world_bank_intl_education.international_education AS edu
INNER JOIN 
    bigquery-public-data.world_bank_intl_education.country_summary AS summary
ON edu.country_code = summary.country_code


SELECT 
    AVG(edu.value) average_value, summary.region
FROM 
    `bigquery-public-data.world_bank_intl_education.international_education` AS edu
INNER JOIN 
    `bigquery-public-data.world_bank_intl_education.country_summary` AS summary
ON edu.country_code = summary.country_code
WHERE summary.region IS NOT null
GROUP BY summary.region
ORDER BY average_value DESC

--------------------NCAAA bsketball data-----------------------------

SELECT
 seasons.market AS university,
 seasons.name AS team_name,
 seasons.wins,
 seasons.losses,
 seasons.ties,
 mascots.mascot AS team_mascot
FROM
 `bigquery-public-data.ncaa_basketball.mbb_historical_teams_seasons` AS seasons
JOIN
 `bigquery-public-data.ncaa_basketball.mascots` AS mascots
ON
 seasons.team_id = mascots.id
WHERE
 seasons.season = 1984
 AND seasons.division = 1
ORDER BY
 seasons.market



