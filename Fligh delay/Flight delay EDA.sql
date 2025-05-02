-- EDA ANALYSIS
USE [flight-delays]
GO

---------------------------------------------------------------------------------------------------------------------------------------

-- Airline Performance:
	-- What is the average delay per airline?
	-- Which airline has the highest number of delayed flights?
	-- Which airline has the most on-time flights?


-- What is the average delay per airline?

SELECT TOP 1000 * 
FROM dbo.flights

SELECT * 
FROM 
dbo.airlines


SELECT * 
FROM 
dbo.airports

SELECT 
	AL.AIRLINE AIRLINE,
	AVG(FL.DEPARTURE_DELAY) AVG_TIME
FROM dbo.airlines AL
LEFT JOIN  
	dbo.flights FL ON
			AL.IATA_CODE = FL.AIRLINE
GROUP BY AL.AIRLINE
ORDER BY AVG_TIME DESC;



-- Which airline has the highest number of delayed flights?

SELECT TOP 1
	AL.AIRLINE AIRLINE,
	COUNT(*) AS Total_Flights,
	COUNT(CASE WHEN FL.DEPARTURE_DELAY > 0 THEN 1 END ) AS DELAYED_FLIGHTS
FROM dbo.airlines AL
LEFT JOIN  
	dbo.flights FL ON
			AL.IATA_CODE = FL.AIRLINE
GROUP BY AL.AIRLINE
ORDER BY DELAYED_FLIGHTS DESC;



-- Which airline has the most on-time flights?
SELECT TOP 1
	AL.AIRLINE AIRLINE,
	COUNT(*) AS Total_Flights,
	COUNT(CASE WHEN FL.DEPARTURE_DELAY <= 0 THEN 1 END ) AS NO_DELAYED_FLIGHTS
FROM dbo.airlines AL
LEFT JOIN  
	dbo.flights FL ON
			AL.IATA_CODE = FL.AIRLINE
GROUP BY AL.AIRLINE
ORDER BY NO_DELAYED_FLIGHTS DESC;


---------------------------------------------------------------------------------------------------------------------------------------
-- Airport Performance:
	-- Which airport has the highest departure delays?
	-- Which airport has the most number of delayed arrivals?


-- Which airport has the highest departure delays?
SELECT TOP 1
	FL.ORIGIN_AIRPORT AIRPORT_CODE,
	AP.AIRPORT AIRPORT,
	COUNT(FL.ORIGIN_AIRPORT) AS Total_Flights,
	AVG(FL.DEPARTURE_DELAY ) AS DELAYED_FLIGHTS_AVG
FROM dbo.airports AP
JOIN  
	dbo.flights FL ON
			AP.IATA_CODE = FL.ORIGIN_AIRPORT
WHERE FL.DEPARTURE_DELAY IS NOT NULL
GROUP BY FL.ORIGIN_AIRPORT, AP.AIRPORT
ORDER BY DELAYED_FLIGHTS_AVG DESC;


-- Which airport has the most number of delayed arrivals?
SELECT TOP 1
	FL.DESTINATION_AIRPORT AIRPORT_CODE,
	AP.AIRPORT AIRPORT,
	COUNT(FL.DESTINATION_AIRPORT) AS Total_Flights,
	COUNT(CASE WHEN ARRIVAL_DELAY > 0 THEN 1 END) AS DELAYED_FLIGHTS_AVG
FROM dbo.airports AP
JOIN  
	dbo.flights FL ON
			AP.IATA_CODE = FL.DESTINATION_AIRPORT
GROUP BY FL.DESTINATION_AIRPORT, AP.AIRPORT
ORDER BY DELAYED_FLIGHTS_AVG DESC;

---------------------------------------------------------------------------------------------------------------------------------------

--Time-Based Analysis
	-- How do delays vary by month or day of the week
	-- What time of day (morning, afternoon, evening) has the most delays
	-- How does the number of delays change across years?

-- How do delays vary by month or day of the week
SELECT 
	MONTH(DATE_NEW) AS MONTH_OF_FLIGHT,
	DAY_OF_WEEK,
	COUNT(*) as TOTAL_FLIGHTS,
	COUNT(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 END) AS DELAYED_FLIGHTS,
	AVG(DEPARTURE_DELAY) AS AVG_DEPARTURE_DELAY
FROM dbo.flights
GROUP BY MONTH(DATE_NEW) , DAY_OF_WEEK
ORDER BY MONTH_OF_FLIGHT, DAY_OF_WEEK;

-- What time of day (morning, afternoon, evening) has the most delays
WITH TIME_CTE AS(
SELECT 
	CASE
		WHEN DATEPART(HOUR, ACTUAL_DEPARTURE_TIME) >= 6 AND DATEPART(HOUR, ACTUAL_DEPARTURE_TIME) < 12 THEN 'MORNING 6-12'
		WHEN DATEPART(HOUR, ACTUAL_DEPARTURE_TIME) >= 12 AND DATEPART(HOUR, ACTUAL_DEPARTURE_TIME) < 18 THEN 'AFTERNOON 12-18'
		WHEN DATEPART(HOUR, ACTUAL_DEPARTURE_TIME) >= 18 AND DATEPART(HOUR, ACTUAL_DEPARTURE_TIME) < 24 THEN 'EVENING 18-24'
		WHEN DATEPART(HOUR, ACTUAL_DEPARTURE_TIME) >= 0 AND DATEPART(HOUR, ACTUAL_DEPARTURE_TIME) < 6 THEN 'NIGHT 0-6'
	END AS TIMING_OF_FLIGHTS,
	DEPARTURE_DELAY
FROM dbo.flights
)
SELECT 
	TIMING_OF_FLIGHTS,
	COUNT (*) AS TOTAL_FLIGHT,
	AVG(DEPARTURE_DELAY) AVG_DEPARTURE_DELAY,
	SUM(DEPARTURE_DELAY) SUM_DEPARTURE_DELAY
FROM TIME_CTE
GROUP BY TIMING_OF_FLIGHTS
ORDER BY AVG_DEPARTURE_DELAY;


-- How does the number of delays change across years?

SELECT 
	YEAR,
	COUNT(*) TOTAL_FLIGHIS,
	SUM(CASE WHEN ARRIVAL_DELAY > 0 THEN 1 ELSE 0 END) AS ARRIVAL_DELAYS,
	SUM(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END) AS DEPATURE_DELAYS
FROM dbo.flights
GROUP BY YEAR
ORDER BY YEAR;

---------------------------------------------------------------------------------------------------------------------------------------


-- Flight Route Analysis:
	-- Which flight routes (origin ➝ destination) have the most delays?
	-- What are the average departure and arrival delays for the top 5 most common flight routes?

-- Which flight routes (origin ➝ destination) have the most delays?
SELECT TOP 5
    a1.AIRPORT AS ORIGIN_AIRPORT_NAME,
    a2.AIRPORT AS DESTINATION_AIRPORT_NAME,
	f.ORIGIN_AIRPORT,
	f.DESTINATION_AIRPORT,
	COUNT(*) AS TOTAL_NUM_FLIGHTS,
    AVG(DEPARTURE_DELAY) AS AVG_DELAYED_DEPARTURE,
    AVG(ARRIVAL_DELAY) AS AVG_DELAYED_ARRIVAL,
	SUM(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END) AS NUM_DELAYED_FLIGHTS ,
	 CAST( (SUM(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS DECIMAL(5,2)) AS PERCENT_DELAYED
FROM dbo.flights f
LEFT JOIN dbo.airports a1 ON f.ORIGIN_AIRPORT = a1.IATA_CODE
LEFT JOIN dbo.airports a2 ON f.DESTINATION_AIRPORT = a2.IATA_CODE
WHERE DEPARTURE_DELAY IS NOT NULL
GROUP BY 
    a1.AIRPORT, a2.AIRPORT, f.ORIGIN_AIRPORT, f.DESTINATION_AIRPORT
HAVING COUNT(*) > 50
ORDER BY  AVG_DELAYED_DEPARTURE DESC;

-- What are the average departure and arrival delays for the top 5 most common flight routes?

WITH TopRoutes AS 
(
	SELECT TOP 5
		ORIGIN_AIRPORT,
		DESTINATION_AIRPORT,
		COUNT(*) AS FLIGHT_COUNT
	FROM dbo.flights
	GROUP BY ORIGIN_AIRPORT, DESTINATION_AIRPORT
	ORDER BY FLIGHT_COUNT DESC
)
SELECT 
	F.ORIGIN_AIRPORT,
	F.DESTINATION_AIRPORT,
	COUNT(*) AS TOTAL_NUM_FLIGHTS,
	AVG(F.DEPARTURE_DELAY) AS AVG_DELAYED_DEPARTURE,
	AVG(F.ARRIVAL_DELAY) AS AVG_DELAYED_ARRIVAL
FROM dbo.flights F
JOIN 
	TopRoutes TR ON F.ORIGIN_AIRPORT = TR.ORIGIN_AIRPORT
AND F.DESTINATION_AIRPORT = TR.DESTINATION_AIRPORT
GROUP BY 
	F.ORIGIN_AIRPORT,
	F.DESTINATION_AIRPORT
ORDER BY TOTAL_NUM_FLIGHTS DESC;




SELECT TOP 5
    a1.AIRPORT AS ORIGIN_AIRPORT_NAME,
    a2.AIRPORT AS DESTINATION_AIRPORT_NAME,
	f.ORIGIN_AIRPORT,
	f.DESTINATION_AIRPORT,
	COUNT(*) AS TOTAL_NUM_FLIGHTS,
    AVG(DEPARTURE_DELAY) AS AVG_DELAYED_DEPARTURE,
    AVG(ARRIVAL_DELAY) AS AVG_DELAYED_ARRIVAL
FROM dbo.flights f
LEFT JOIN dbo.airports a1 ON f.ORIGIN_AIRPORT = a1.IATA_CODE
LEFT JOIN dbo.airports a2 ON f.DESTINATION_AIRPORT = a2.IATA_CODE
WHERE DEPARTURE_DELAY IS NOT NULL
GROUP BY 
    a1.AIRPORT, a2.AIRPORT, f.ORIGIN_AIRPORT, f.DESTINATION_AIRPORT
HAVING COUNT(*) > 50
ORDER BY  TOTAL_NUM_FLIGHTS DESC;

---------------------------------------------------------------------------------------------------------------------------------------

-- Delay Causes:
	-- Is there any correlation between the distance of the flight and delay?
	-- Do certain aircraft (tail numbers) have a history of being more delayed?

-- Is there any correlation between the distance of the flight and delay?
WITH Mean_CTE AS
(
	SELECT 
		ROUND(AVG(CAST(DISTANCE AS FLOAT)), 2) Mean_Distance,
		ROUND(AVG(CAST(ARRIVAL_DELAY AS FLOAT)), 2) Mean_delay
	FROM dbo.flights
)
SELECT 
	ROUND(SUM((CAST(F.DISTANCE AS FLOAT) - M.Mean_Distance) * (CAST(F.ARRIVAL_DELAY AS FLOAT) - M.Mean_delay)) 
	/
	SQRT(SUM(POWER(CAST(F.DISTANCE AS FLOAT) - M.Mean_Distance, 2)) * SUM(POWER(CAST(F.ARRIVAL_DELAY AS FLOAT) - M.Mean_delay, 2))), 2) AS Correlation,
	M.Mean_Distance,
	M.Mean_delay
FROM dbo.flights F
CROSS JOIN Mean_CTE M
GROUP BY 	M.Mean_Distance,
	M.Mean_delay;

-- There is no meaningful correlation between flight distance and arrival delay in your dataset.
--  So, longer flights are not necessarily more delayed than shorter ones — at least not in a linear, statistically significant way.

-- Do certain aircraft (tail numbers) have a history of being more delayed?
SELECT TOP 10
	TAIL_NUMBER,
	COUNT(*) AS Total_Flights,
	AVG(ARRIVAL_DELAY) AS Avg_Arrival_Delay,
	AVG(DEPARTURE_DELAY) AS Avg_Departure_Delay
FROM dbo.flights
WHERE 
	TAIL_NUMBER IS NOT NULL AND 
	ARRIVAL_DELAY IS NOT NULL AND 
	DEPARTURE_DELAY IS NOT NULL
GROUP BY TAIL_NUMBER
HAVING COUNT(*) > 30
ORDER BY Avg_Departure_Delay DESC;

---------------------------------------------------------------------------------------------------------------------------------------

--On-time vs. Delayed:
	-- What percentage of flights are on-time versus delayed?
	-- How do delays affect specific airlines or airports?

-- What percentage of flights are on-time versus delayed?
SELECT 
	COUNT(*) AS Total_Flights,
	SUM(CASE WHEN ARRIVAL_DELAY > 0 THEN 1 ELSE 0 END) AS DELAYED_FLIGHTS,
	SUM(CASE WHEN ARRIVAL_DELAY <= 0 THEN 1 ELSE 0 END) AS ON_TIME_FLIGHTS,
	CAST(100.0 * SUM(CASE WHEN ARRIVAL_DELAY > 0 THEN 1 ELSE 0 END) / COUNT(*)AS DECIMAL(5,2)) AS DELAYED_FLIGHTS_PERCENT,
	CAST(100.0 * SUM(CASE WHEN ARRIVAL_DELAY <= 0 THEN 1 ELSE 0 END) / COUNT(*)AS DECIMAL(5,2)) AS ON_TIME_FLIGHTS_PERCENT
FROM dbo.flights


-- How do delays affect specific airlines or airports?
	-- Average Delay per Airline
	SELECT
		A.AIRLINE,
		A.IATA_CODE,
		COUNT(F.FLIGHT_NUMBER) AS TOTAL_AIRLINE,
		AVG(DEPARTURE_DELAY) AS DEPARTURE_DELAY,
		AVG(ARRIVAL_DELAY) AS ARRIVAL_DELAY
	FROM dbo.flights F
	RIGHT JOIN DBO.airlines A ON
		A.IATA_CODE = F.AIRLINE
	WHERE ARRIVAL_DELAY IS NOT NULL AND 
		  DEPARTURE_DELAY IS NOT NULL
	GROUP BY A.AIRLINE, A.IATA_CODE
	ORDER BY ARRIVAL_DELAY DESC;


	-- Average Delay per Origin Airport
	SELECT 
		ORIGIN_AIRPORT,
		COUNT(*) AS Total_Flights,
		AVG(DEPARTURE_DELAY) AVG_DEPARTURE_DELAY
	FROM dbo.flights
	GROUP BY ORIGIN_AIRPORT
	ORDER BY AVG_DEPARTURE_DELAY DESC;


	-- Average Delay per Destination Airport
	SELECT 
		DESTINATION_AIRPORT,
		COUNT(*) AS Total_Flights,
		AVG(ARRIVAL_DELAY) AVG_ARRIVAL_DELAY
	FROM dbo.flights
	GROUP BY DESTINATION_AIRPORT
	ORDER BY AVG_ARRIVAL_DELAY DESC;


	-- Significant Delay Frequency (>15 mins) by Airline
	SELECT
		A.AIRLINE,
		A.IATA_CODE,
		COUNT(F.FLIGHT_NUMBER) AS TOTAL_AIRLINE,
		SUM(CASE WHEN F.DEPARTURE_DELAY > 15 THEN 1 ELSE 0 END) AS 'DEPARTURE_DELAY_>15',
		SUM(CASE WHEN F.ARRIVAL_DELAY > 15 THEN 1 ELSE 0 END) AS 'ARRIVAL_DELAY_>15',
		CAST(SUM(CASE WHEN F.ARRIVAL_DELAY > 15 THEN 1 ELSE 0 END) * 100 / COUNT(*) AS DECIMAL(5,2)) AS ARRIVAL_DELAY_PERCENATAGE
	FROM dbo.flights F
	RIGHT JOIN DBO.airlines A ON
		A.IATA_CODE = F.AIRLINE
	WHERE ARRIVAL_DELAY IS NOT NULL AND 
		  DEPARTURE_DELAY IS NOT NULL
	GROUP BY A.AIRLINE, A.IATA_CODE
	ORDER BY ARRIVAL_DELAY_PERCENATAGE DESC;

-- Delay Trend by Day of Week
SELECT 
	DATENAME(WEEKDAY, DATE_NEW) AS DAY_NAME,
	COUNT(*) TOTAL_FLIGHT,
	AVG(DEPARTURE_DELAY) AS AVG_DEPARTURE_DELAY
FROM dbo.flights
GROUP BY DATENAME(WEEKDAY, DATE_NEW)
ORDER BY AVG_DEPARTURE_DELAY DESC;


--  Carrier-Wise Delay Cause Analysis
SELECT 
	AI.AIRLINE,
	ROUND(AVG(CAST(F.AIRLINE_DELAY AS FLOAT)),2) AS Avg_Airline_Delay,
	ROUND(AVG(CAST(F.WEATHER_DELAY AS FLOAT)),2) AS Avg_Weather_Delay,
	ROUND(AVG(CAST(F.AIR_SYSTEM_DELAY AS FLOAT)),2) AS Avg_Airsystem_Delay,
	ROUND(AVG(CAST(F.SECURITY_DELAY AS FLOAT)),2) AS Avg_Security_Delay,
	ROUND(AVG(CAST(F.LATE_AIRCRAFT_DELAY AS FLOAT)),2) AS Avg_LateAircraft_Delay
FROM dbo.flights F
LEFT JOIN dbo.airlines AI ON F.AIRLINE = AI.IATA_CODE
WHERE AI.AIRLINE IS NOT NULL AND 
	  F.AIRLINE_DELAY IS NOT NULL AND 
	  F.WEATHER_DELAY IS NOT NULL AND 
	  F.AIR_SYSTEM_DELAY IS NOT NULL AND 
	  F.SECURITY_DELAY IS NOT NULL AND 
	  F.LATE_AIRCRAFT_DELAY IS NOT NULL
GROUP BY AI.AIRLINE
ORDER BY Avg_Airline_Delay DESC;


---------------------------------------------------------------------------------------------------------------------------------------
-- ADA
-- Trend Analysis: how flight delays trend over time. Analyze if delays increase during specific months or seasons.
SELECT 
	YEAR(DATE_NEW) YEARS,
	MONTH(DATE_NEW) MONTHS,
	AVG(DEPARTURE_DELAY) AS AVG_DEPARTURE_DELAY,
	AVG(ARRIVAL_DELAY) AS AVG_ARRIVAL_DELAY
FROM dbo.flights
GROUP BY 
	YEAR(DATE_NEW),
	MONTH(DATE_NEW)
ORDER BY YEARS, MONTHS


---------------------------------------------------------------------------------------------------------------------------------------
-- Which Airline Should You Fly on to Avoid Significant Delays?
SELECT A.AIRLINE, 
       AVG(DEPARTURE_DELAY) AS Avg_Departure_Delay,
	   AVG(ARRIVAL_DELAY) AS Avg_Arrival_Delay,
       CAST(COUNT(CASE WHEN DEPARTURE_DELAY > 0 THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Departure_Delay_Percentage,
	   CAST(COUNT(CASE WHEN ARRIVAL_DELAY > 0 THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Arrival_Delay_Percentage
FROM dbo.flights F
LEFT JOIN dbo.airlines A ON F.AIRLINE = A.IATA_CODE
GROUP BY A.AIRLINE
ORDER BY Departure_Delay_Percentage, Arrival_Delay_Percentage;


---------------------------------------------------------------------------------------------------------------------------------------

-- CRAETING A DETAILED VIEW FOR FLIGHTS TABLE

CREATE VIEW vw_FlightAnalysis AS
SELECT 
	-- FLIGHT METADATA
	F.YEAR,
	F.MONTH,
	F.DAY,
	F.DAY_OF_WEEK,
	TRY_CAST(f.DATE_NEW AS DATE) AS FLIGHT_DATE,
	F.AIRLINE,
	AL.AIRLINE AS AIRLINE_NAME,
	F.FLIGHT_NUMBER,
	F.TAIL_NUMBER,

	-- ROUTES AND AIRPORT INFO
	F.ORIGIN_AIRPORT,
	AP1.AIRPORT AS ORIGIN_AIRPORT_NAME,
	AP1.CITY AS ORIGIN_CITY,
	AP1.STATE AS ORIGIN_STATE,
	AP1.COUNTRY AS ORIGIN_COUNTRY,

	F.DESTINATION_AIRPORT,
	AP2.AIRPORT AS DESTINATION_AIRPORT_NAME,
	AP2.CITY AS DESTINATION_CITY,
	AP2.STATE AS DESTINATION_STATE,
	AP2.COUNTRY AS DESTINATION_COUNTRY,

	F.DISTANCE,

	-- TIMES
	F.SCHEDULED_DEPATURE_TIME,
	F.ACTUAL_DEPARTURE_TIME,
	F.SCHEDULED_ARRIVAL_TIME,
	F.ARRIVAL_TIME_TIME,

	-- DELAY INFO
	F.DEPARTURE_DELAY,
	F.ARRIVAL_DELAY,
	F.AIR_SYSTEM_DELAY,
	F.SECURITY_DELAY,
	F.AIRLINE_DELAY,
	F.LATE_AIRCRAFT_DELAY,
	F.WEATHER_DELAY,

	-- CALCULATED FIELDS
	COALESCE(F.DEPARTURE_DELAY, 0) + COALESCE(F.ARRIVAL_DELAY, 0) AS TOTAL_DELAY,
	IIF(F.DEPARTURE_DELAY > 15 OR F.ARRIVAL_DELAY > 15, 1, 0) AS IS_SIGNIFICANT_DELAY,
	IIF(F.DIVERTED = 1, 1, 0) AS IS_DIVERTED,
    IIF(F.CANCELLED = 1, 1, 0) AS IS_CANCELLED,

	-- Cancellation info
    F.CANCELLATION_REASON,

    -- Other time info
    F.ELAPSED_TIME,
    F.AIR_TIME,
    F.TAXI_OUT,
    F.TAXI_IN,
    F.SCHEDULED_TIME,

    -- Timestamp helpers
    F.WHEELS_OFF_TIME,
    F.WHEELS_ON_TIME

FROM dbo.flights F
LEFT JOIN dbo.airlines AL ON F.AIRLINE = AL.IATA_CODE
LEFT JOIN dbo.airports AP1 ON F.ORIGIN_AIRPORT = AP1.IATA_CODE
LEFT JOIN dbo.airports AP2 ON F.DESTINATION_AIRPORT = AP2.IATA_CODE
WHERE F.DATE_NEW IS NOT NULL;





