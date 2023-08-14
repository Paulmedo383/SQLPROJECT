SELECT *
FROM dbo.DEATH_RATE

--SELECT*
--FROM dbo.VACCIN_RATE



SELECT CAST (total_deaths AS decimal) / cast ( total_cases as decimal) * 100 as dess
from SQLPROJECT.dbo.DEATH_RATE 
WHERE total_cases IS NOT NULL AND total_deaths is not null

--LOOKINGA AT TOTAL_CASES VS TOTAL_DEATHS
--SHOW TOTAL NUMBER OF PEOPLE WHO DIED FROM COVID

SELECT LOCATION, DATE,population, total_cases,total_deaths,  CAST (total_deaths AS decimal) / cast ( total_cases as decimal)  * 100  AS DEATHRATE
FROM SQLPROJECT.dbo.DEATH_RATE
WHERE total_cases IS NOT NULL AND total_deaths is not null 
ORDER BY 1,2

--LOOKING AT POPULAION VS DEATH_RATE
--SHOWS AMOUT OF PEOPLE THAT GOT COVID BY THE DAY

SELECT LOCATION, DATE,population,total_cases, CAST  (total_cases AS decimal) / CAST (population AS decimal ) * 100  AS INFECTEDRATE
FROM SQLPROJECT.dbo.DEATH_RATE
WHERE location LIKE '%NiGERIA%' 
ORDER BY INFECTEDRATE DESC

--LOKING AT THE HIGHEST NUMBER OF INFECTION RATE COMPARE PERCENTAGE OF INFECTION RATE 

SELECT LOCATION,population,MAX (total_cases) AS TOPCOUNTRIES, MAX (CAST(total_cases AS decimal) /CAST( population AS decimal )) * 100  AS INFECTEDRATE
FROM SQLPROJECT.dbo.DEATH_RATE
--WHERE location LIKE '%NiGERIA%'
GROUP BY location, population
ORDER BY TOPCOUNTRIES DESC 

--LOOKING AT THE continent WITH THE HIGHEST COUNT OF DEATH_RATE

SELECT continent, sum (Cast(total_deaths as decimal)) as totaldeathcount
FROM SQLPROJECT.dbo.DEATH_RATE
where continent is not null
GROUP  BY continent


--LOOKING AT THE country WITH THE HIGHEST COUNT OF DEATH_RATE

select location, sum(cast(total_deaths as decimal)) as countrydeath
from SQLPROJECT.dbo.DEATH_RATE 
where continent is not null and total_deaths is not null
group by location
order by countrydeath desc 

/* LOOKING WORLD WIDE DEATH8*/ 

select sum(cast(total_deaths as decimal)) as GLOBAL_DEATH
from SQLPROJECT.dbo.DEATH_RATE

/* LOOKING AT NEW_CASES VS NEW_DEATHS*/

SELECT LOCATION, DATE, POPULATION,NEW_CASES,new_deaths, CAST (NEW_DEATHS AS decimal) / CAST(NEW_CASES AS decimal) * 100 AS NEW_DEATH_RATE
FROM  SQLPROJECT.dbo.DEATH_RATE
WHERE location LIKE '%NiGERIA%' AND location IS NOT NULL

/* looking at total poulation vs vaccintion*/

SELECT dbo.DEATH_RATE.continent,dbo.DEATH_RATE.location,dbo.DEATH_RATE.population,dbo.DEATH_RATE.date,dbo.VACCIN_RATE.new_vaccinations,
SUM(CAST(dbo.VACCIN_RATE.new_vaccinations AS decimal)) OVER (PARTITION BY dbo.DEATH_RATE.location order by dbo.DEATH_RATE.location,dbo.DEATH_RATE.date ) AS total_vaccins
FROM SQLPROJECT.dbo.DEATH_RATE
JOIN SQLPROJECT.dbo.VACCIN_RATE
ON dbo.DEATH_RATE.location = dbo.VACCIN_RATE.location
AND dbo.DEATH_RATE.date = dbo.VACCIN_RATE.date
WHERE dbo.DEATH_RATE.continent IS NOT NULL and dbo.VACCIN_RATE.new_vaccinations is not null
ORDER BY 1,2,3


--temptable 
DROP TABLE IF EXISTS #ROLLING
create TABLE #ROLLING
(CONTINENT NVARCHAR (100),
LOCATION NVARCHAR(100),
POPULATION NUMERIC,
DATE DATETIME,
NEW_VACCINATIONS NUMERIC,
TOTAL_VACCINS NUMERIC)

INSERT INTO #ROLLING
SELECT dbo.DEATH_RATE.continent,dbo.DEATH_RATE.location,dbo.DEATH_RATE.population,dbo.DEATH_RATE.date,dbo.VACCIN_RATE.new_vaccinations,
SUM(CAST(dbo.VACCIN_RATE.new_vaccinations AS decimal)) OVER (PARTITION BY dbo.DEATH_RATE.location order by dbo.DEATH_RATE.location,dbo.DEATH_RATE.date ) AS total_vaccins
FROM SQLPROJECT.dbo.DEATH_RATE
JOIN SQLPROJECT.dbo.VACCIN_RATE
ON dbo.DEATH_RATE.location = dbo.VACCIN_RATE.location
AND dbo.DEATH_RATE.date = dbo.VACCIN_RATE.date
WHERE dbo.DEATH_RATE.continent IS NOT NULL and dbo.VACCIN_RATE.new_vaccinations is not null
--ORDER BY 1,2,3

SELECT *,  (POPULATION / total_vaccins)  * 100
FROM #ROLLING

SELECT *,
CASE
WHEN POPULATION = 0 AND TOTAL_VACCINS = 0 THEN NULL
ELSE (POPULATION/TOTAL_VACCINS) *100
END
FROM #ROLLING


