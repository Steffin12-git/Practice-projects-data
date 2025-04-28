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


