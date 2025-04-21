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




-- 5. Name Analysis
-- Can you extract titles from the names (e.g., Mr., Mrs., Miss)?
-- Did any specific title have higher survival?
WITH NAMING AS
(
	SELECT 
	PassengerId,
	SUBSTRING(Name, CHARINDEX(',', Name) + 2, CHARINDEX('.', Name) - CHARINDEX(',', Name) - 2) Title,
	Survived
	FROM dbo.train
)
SELECT
Title,
COUNT(*) Total_Passenger,
SUM(CAST(Survived AS INT)) Survived_Passengers,
ROUND(SUM(CAST(Survived AS FLOAT)) / COUNT(*), 2) Survived_Rate
FROM NAMING
GROUP BY Title
ORDER BY Survived_Rate DESC, Total_Passenger DESC;

-- Were certain titles more common in a specific Pclass?
WITH TITLE AS
(
	SELECT 
		SUBSTRING(Name, CHARINDEX(',', Name) + 2, CHARINDEX('.', Name) - CHARINDEX(',', Name) - 2) AS Title,
		Pclass,
		Survived
	FROM dbo.train
)
SELECT 
Title,
Pclass AS Class,
COUNT(*) AS Total_Passenger,
SUM(CAST(Survived AS INT)) Survived_Passengers,
ROUND(SUM(CAST(Survived AS FLOAT)) / COUNT(*), 2) Survived_Rate
FROM
TITLE
GROUP BY Title, Pclass
ORDER BY Title, Pclass;




-- 6). Socioeconomic Status
--Can you create a new field called SES_Level?
-- Do high SES passengers survive more?
WITH TITLE AS
(
	SELECT 
		SUBSTRING(Name, CHARINDEX(',', Name) + 2, CHARINDEX('.', Name) - CHARINDEX(',', Name) - 2) AS Title,
		Pclass,
		Survived,
		Fare
	FROM dbo.train
	WHERE Name IS NOT NULL
)
SELECT 
	CASE
		WHEN Pclass = 1  AND Title IN ('Capt', 'Col', 'Don', 'Dr', 'Jonkheer', 'Lady', 'Major', 'Rev', 'Sir', 'the Countess') THEN 'High SES'
		WHEN Pclass = 2  AND Title IN ('Mr', 'Mrs', 'Ms', 'Mme', 'Mlle') THEN 'Middle SES'
		WHEN Pclass = 3  AND Title IN ('Miss', 'Master') THEN 'Low SES'
		WHEN Pclass = 1 THEN 'High SES'
		WHEN Pclass = 2 THEN 'Middle SES'
		WHEN Pclass = 3 THEN 'Low SES'
		ELSE 'UNKNOWN'
	END AS SES_LEVEL,
	AVG(CAST(Fare AS FLOAT)) Average_price,
	COUNT(*) Total_Passenger,
	SUM(CAST(Survived AS INT)) Survived_Passengers,
	ROUND(SUM(CAST(Survived AS FLOAT)) / COUNT(*), 2) Survived_Rate
FROM TITLE
GROUP BY CASE
	WHEN  Pclass = 1 AND Title IN ('Capt', 'Col', 'Don', 'Dr', 'Jonkheer', 'Lady', 'Major', 'Rev', 'Sir', 'the Countess') THEN 'High SES'
	WHEN  Pclass = 2 AND Title IN ('Mr', 'Mrs', 'Ms', 'Mme', 'Mlle') THEN 'Middle SES'
	WHEN  Pclass = 3 AND Title IN ('Miss', 'Master') THEN 'Low SES'
	WHEN  Pclass = 1 THEN 'High SES'
	WHEN  Pclass = 2 THEN 'Middle SES'
	WHEN  Pclass = 3 THEN 'Low SES'
	ELSE 'UNKNOWN'
END
ORDER BY Survived_Rate;










--- 9. Survival Prediction
-- Can you simulate who is most likely to survive based on Sex, Pclass, Age, Fare, Title, FamilySize, etc.?
-- Build a rule-based prediction column and test its accuracy vs real data.
with cte as
(
	SELECT *,
	SUBSTRING(Name, CHARINDEX(',', Name) + 2, CHARINDEX('.', Name) - CHARINDEX(',', Name) - 2) AS Title
	from dbo.train
),
prediction AS (
	SELECT 
		PassengerId,
		Title,
		(SibSp + Parch) AS FamilySize,
		TRY_CAST(Survived AS INT) Survived,
		CASE 
			WHEN Sex = 'female' AND Pclass IN (1, 2) THEN 1
			WHEN Sex = 'female' AND Pclass = 3 AND TRY_CAST(Age AS INT) <= 40 THEN 1
			WHEN Sex = 'male' AND TRY_CAST(Age AS INT) <= 10 THEN 1
			WHEN TRY_CAST(Fare AS FLOAT) >= 100 AND Pclass = 1 THEN 1
			ELSE 0
		END AS Predicted_Survived
	FROM cte
	WHERE TRY_CAST(Age AS INT) IS NOT NULL
)
SELECT 
    COUNT(*) AS total_records,
    SUM(CASE WHEN Survived = Predicted_Survived THEN 1 ELSE 0 END) AS correct_predictions,
    SUM(CASE WHEN Survived = Predicted_Survived THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS accuracy_percentage
FROM prediction;
