USE Titanic
GO

SELECT *
FROM dbo.train;


-- overal suvival rate of passgengers
SELECT 
COUNT(PassengerId) total_passgers,
SUM(cast (Survived AS int)) total_survived_passngerm,
ROUND(SUM(cast (Survived AS float)) / COUNT(*),2) as survival_rate
FROM dbo.train;


-- survival rates differ based on gender
SELECT 
Sex,
SUM(cast (Survived AS int)) total_survived_passngerm,
ROUND(SUM(cast (Survived AS float)) / COUNT(*),2) as survival_rate
FROM dbo.train
GROUP BY Sex;

-- Did age play a significant role in survival?
WITH age_group AS
(
	SELECT 
	*,
	CASE
		WHEN TRY_CAST(Age AS float) < 10 then '0-10'
		WHEN TRY_CAST(Age AS float) BETWEEN 10 AND 20 then '10-20'
		WHEN TRY_CAST(Age AS float) BETWEEN 21 AND 40 then '20-40'
		WHEN TRY_CAST(Age AS float) BETWEEN 41 AND 60 then '40-60'
		WHEN TRY_CAST(Age AS float) >= 61 THEN 'OVER 61'
	END AS AGE_GROUPS
	FROM dbo.train
	WHERE Age is not null
)
SELECT 
AGE_GROUPS,
COUNT(*) total_passgers,
SUM(CAST(Survived AS INT)) AS total_survived_passengers,
round(SUM(CAST(Survived AS FLOAT)) / COUNT(*), 2) AS survival_rate
FROM age_group
GROUP BY AGE_GROUPS
ORDER BY survival_rate;

-- 2) FARE ANALYSIS
-- average fare by Pclass
SELECT 
CASE
	WHEN Pclass = 1 THEN '1st Class'
	WHEN Pclass = 2 THEN '2nd Class'
	WHEN Pclass = 3 THEN '3rd Class'
END AS Ticket_Class,
ROUND(AVG(DISTINCT CAST(Fare AS FLOAT)), 2) Total_Fare
FROM 
dbo.train
GROUP BY Pclass
ORDER BY AVG(DISTINCT CAST(Fare AS FLOAT));

-- SURVIAVAL ANALYSIS OF PASSENGER DEPENDING THE CLASS THEY HAVE BOOKED
-- Did passengers who paid higher fares survive more?
SELECT 
Pclass,
ROUND(AVG (CAST(Fare AS FLOAT)),2)  Aveage_Fare,
COUNT(PassengerId) Total_passanger,
SUM(CAST(Survived AS INT)) AS total_survived_passengers,
round(SUM(CAST(Survived AS FLOAT)) / COUNT(*), 2) AS survival_rate
FROM 
dbo.train
GROUP BY Pclass
ORDER BY survival_rate DESC;

--What is the fare distribution by embarkation port?
SELECT 
CASE
	WHEN Embarked = 'C' THEN 'Cherbourg'
	WHEN Embarked = 'Q' THEN 'Queenstown'
	WHEN Embarked = 'S' THEN 'Southampton'
END AS Embarked,
COUNT(PassengerId) Total_passanger,
SUM(CAST(Survived AS INT)) AS total_survived_passengers,
round(SUM(CAST(Survived AS FLOAT)) / COUNT(*), 2) AS survival_rate,
ROUND(AVG (CAST(Fare AS FLOAT)),2)  Aveage_Fare
FROM 
dbo.train
WHERE Embarked IS NOT NULL
GROUP BY CASE
	WHEN Embarked = 'C' THEN 'Cherbourg'
	WHEN Embarked = 'Q' THEN 'Queenstown'
	WHEN Embarked = 'S' THEN 'Southampton'
END
ORDER BY survival_rate DESC;
