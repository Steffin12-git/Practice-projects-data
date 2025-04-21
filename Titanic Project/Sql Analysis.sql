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




-- 3) Family Relationships
-- Did people with family (SibSp > 0 or Parch > 0) survive more?
SELECT
	CASE 
		WHEN SibSp + Parch = 0 THEN 'Alone'
		ELSE 'With Family'
	END FAMILY,
	COUNT(*) AS TotaL_population,
	SUM(CAST(Survived AS INT)) AS 'Total_Survived',
	ROUND(SUM(CAST(Survived AS FLOAT)) / COUNT(*), 2) AS survival_rate
FROM dbo.train
GROUP BY 
	CASE 
		WHEN SibSp + Parch = 0 THEN 'Alone'
		ELSE 'With Family'
	END;

-- What is the average family size and its correlation with survival?
SELECT
	(SibSp + Parch) 'Family_Size',
	COUNT(*) AS TotaL_population,
	SUM(CAST(Survived AS INT)) AS 'Total_Survived',
	ROUND(SUM(CAST(Survived AS FLOAT)) / COUNT(*), 2) AS survival_rate
FROM dbo.train
WHERE (SibSp + Parch) <= 10
GROUP BY (SibSp + Parch)
ORDER BY Family_Size;


SELECT AVG(CAST(SibSp + Parch AS FLOAT)) AS avg_family_size
FROM dbo.train;




-- 4. Embarkation Port Analysis
-- 1) Which port had the highest number of boarders?
SELECT 
CASE
	WHEN Embarked = 'C' THEN 'Cherbourg'
	WHEN Embarked = 'Q' THEN 'Queenstown'
	WHEN Embarked = 'S' THEN 'Southampton' 
END Embarked_Ports,
COUNT(*) No_of_boarders
FROM 
dbo.train
GROUP BY CASE
	WHEN Embarked = 'C' THEN 'Cherbourg'
	WHEN Embarked = 'Q' THEN 'Queenstown'
	WHEN Embarked = 'S' THEN 'Southampton' 
END
ORDER BY No_of_boarders DESC;

-- 2) What was the survival rate per embarkation port?
WITH PORT_DETAILS AS
(
	SELECT 
		CASE
			WHEN Embarked = 'C' THEN 'Cherbourg'
			WHEN Embarked = 'Q' THEN 'Queenstown'
			WHEN Embarked = 'S' THEN 'Southampton' 
		END Embarked_Ports,
		COUNT(*) AS No_of_boarders,
		SUM(CAST(Survived AS INT)) AS Total_Survived,
		ROUND(SUM(CAST(Survived AS FLOAT)) / COUNT(*), 2) AS survival_rate
	FROM 
	dbo.train
	GROUP BY CASE
		WHEN Embarked = 'C' THEN 'Cherbourg'
		WHEN Embarked = 'Q' THEN 'Queenstown'
		WHEN Embarked = 'S' THEN 'Southampton' 
	END
)
SELECT 
	Embarked_Ports,
	No_of_boarders,
	Total_Survived,
	survival_rate
FROM
PORT_DETAILS
ORDER BY survival_rate DESC;


-- 3) Was any port associated with higher fare or class?
WITH Fare_analaysis AS
(
	SELECT
		CASE
			WHEN Embarked = 'C' THEN 'Cherbourg'
			WHEN Embarked = 'Q' THEN 'Queenstown'
			WHEN Embarked = 'S' THEN 'Southampton' 
		END Embarked_Ports,
		Pclass AS Class,
		ROUND(AVG(CAST(Fare AS FLOAT)),2) Average_Fare,
		COUNT(*) AS Total_Passnger
	FROM dbo.train
	WHERE Embarked IN ('C', 'Q', 'S') 
	GROUP BY CASE
		WHEN Embarked = 'C' THEN 'Cherbourg'
		WHEN Embarked = 'Q' THEN 'Queenstown'
		WHEN Embarked = 'S' THEN 'Southampton' 
	END, Pclass
)
SELECT *
FROM Fare_analaysis
ORDER BY Embarked_Ports, Class DESC;




