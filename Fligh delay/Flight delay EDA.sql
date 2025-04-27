-- EDA ANALYSIS
USE [flight-delays]
GO


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