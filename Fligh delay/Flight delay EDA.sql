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

