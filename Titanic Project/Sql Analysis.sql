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


