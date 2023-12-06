SELECT *
FROM PortFolioProject..[covid death]
ORDER BY 3,4

--SELECT *
--FROM [covid vassination] 
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortFolioProject..[covid death]
ORDER BY 1,2

SELECT location,date,total_cases,total_deaths,((CONVERT(FLOAT,total_deaths)/NULLIF(CONVERT(FLOAT,total_cases),0)))*100  AS DEATH_PERCENTAGE
FRom PortFolioProject..[covid death]
WHERE location LIKE '%STATES%'
ORDER BY 1,2
-- COMPARING TOTAL CASES WITH DEATH IN AFRICA
SELECT location,date,total_cases,total_deaths,((CONVERT(FLOAT,total_deaths)/NULLIF(CONVERT(FLOAT,total_cases),0)))*100  AS DEATH_PERCENTAGE
FRom PortFolioProject..[covid death]
WHERE location='AFRICA'
ORDER BY 1,2

-- COMPARING TOTAL CASES WITH POPULATION
SELECT location,date,total_cases,population,(CONVERT(FLOAT,total_cases)/NULLIF(CONVERT(FLOAT,population),0))*100 AS Population_Death
FROM PortFolioProject..[covid death]
WHERE Location='Africa'
ORDER BY 1,2

-- LOOKING AT A COUNTRY WITH THE HIGHEST INFECTION RATE
SELECT location,population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 As HighestPopulationDeath
FROM PortFolioProject..[covid death] 
WHERE location is not NULL
GROUP BY location,population
ORDER BY HighestPopulationDeath DESC

--SHOWING COUNTRY WITH HIGHEST DEATH COUNT PER POPULATION
select location, MAX(CAST(total_deaths AS INT)) as Deathcount
FROM PortFolioProject..[covid death]
WHERE continent is not NULL and location ='Nigeria'
GROUP BY location
ORDER BY Deathcount

-- SHOWING CONTINENT BASED HIGHEST DEATH COUNT  PER POPULATION
SELECT continent,MAX(total_deaths) as DeathCount
FROM PortFolioProject..[covid death]
WHERE continent is not NULL
GROUP BY continent
ORDER BY DeathCount

--SHOWING EACH COUNTRIES BASED ON CONTINENT HIGHEST DEATH COUNT PER POPULATION (africa)
SELECT location,MAX(total_deaths) as DeathCount
FROM PortFolioProject..[covid death]
WHERE continent ='africa'
GROUP BY location
ORDER BY DeathCount

--EUROPE
SELECT location,MAX(total_deaths) as DeathCount
FROM PortFolioProject..[covid death]
WHERE continent ='EUROPE'
GROUP BY location
ORDER BY DeathCount

--SOUTH AMERICA
SELECT location,MAX(total_deaths) as DeathCount
FROM PortFolioProject..[covid death]
WHERE continent ='SOUTH AMERICA'
GROUP BY location
ORDER BY DeathCount

--NORTH AMERICA
SELECT location,MAX(total_deaths) as DeathCount
FROM PortFolioProject..[covid death]
WHERE continent ='NORTH AMERICA'
GROUP BY location
ORDER BY DeathCount

--ASIA
SELECT location,MAX(total_deaths) as DeathCount
FROM PortFolioProject..[covid death]
WHERE continent ='ASIA'
GROUP BY location
ORDER BY DeathCount

--OCEANIA
SELECT location,MAX(total_deaths) as DeathCount
FROM PortFolioProject..[covid death]
WHERE continent ='OCEANIA'
GROUP BY location
ORDER BY DeathCount

--GLOBAL NUMBERS
SELECT SUM(new_cases) AS NewCaseSum,SUM(CAST(new_deaths AS int)) AS NewCaseDeath, (SUM(CAST(new_deaths AS int))/NULLIF((SUM(new_cases)),0))*100 AS DeathPercentage
FROM PortFolioProject..[covid death]
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--VASSCINATION TABLE
SELECT *
FROM PortFolioProject..[covid vassination]

--LOOKING AT TOTAL POPULATION VS VASSCINATION
SELECT DEATH.location,DEATH.continent,population, DEATH.date, vass.new_vaccinations
FROM PortFolioProject..[covid death] DEATH
JOIN PortFolioProject..[covid vassination] VASS
ON DEATH.date=VASS.date 
AND DEATH.location=vass.location
WHERE DEATH.continent IS NOT NULL
ORDER BY 2,1,3

--HAVING SUM OF EACH NEW VASSINATION BY LOCATION
SELECT D.date,D.location,D.continent,D.population,VAS.new_vaccinations,
SUM(CONVERT(bigint, VAS.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location,D.date)  AS AddedVassination
FROM PortFolioProject..[covid death] D
JOIN PortFolioProject..[covid vassination] VAS
ON D.date=VAS.date 
AND D.location=VAS.location
WHERE D.continent IS NOT NULL
ORDER BY D.location,D.date

--CREATING A CTE IN ORDER TO DETERMINE THE NUMBER OF PEOPLE THAT HAS VASSINATED
WITH CTE_POPvsVacc (date,location,continent,population,new_vaccinations,AddedVassination) AS
(SELECT D.date,D.location,D.continent,D.population,VAS.new_vaccinations,
SUM(CONVERT(bigint, VAS.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location,D.date)  AS AddedVassination
FROM PortFolioProject..[covid death] D
JOIN PortFolioProject..[covid vassination] VAS
ON D.date=VAS.date 
AND D.location=VAS.location
WHERE D.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT date,location,continent,population,new_vaccinations, (AddedVassination/population)*100 AS VassinatedPeople
FROM CTE_POPvsVacc

---using a TEM TABLE
DROP TABLE IF EXISTS #POPULATEDVACCINETABLE
CREATE TABLE #POPULATEDVACCINETABLE
(DATE datetime,
location Nvarchar(255),
continent Nvarchar(255),
population numeric,
new_vaccinations numeric,
AddedVassination numeric
)


INSERT INTO #POPULATEDVACCINETABLE
SELECT D.date,D.location,D.continent,D.population,VAS.new_vaccinations,
SUM(CONVERT(bigint, VAS.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location,D.date)  AS AddedVassination
FROM PortFolioProject..[covid death] D
JOIN PortFolioProject..[covid vassination] VAS
ON D.date=VAS.date 
AND D.location=VAS.location
WHERE D.continent IS NOT NULL
ORDER BY D.location,D.date

SELECT date,location,continent,population,new_vaccinations, (AddedVassination/population)*100 AS VassinatedPeople
FROM #POPULATEDVACCINETABLE


--CREATING VIEW TO STORE DATA FOR VISUALIZATION 
CREATE VIEW  POPULATIONVACCINETABLE AS 
SELECT D.date,D.location,D.continent,D.population,VAS.new_vaccinations,
SUM(CONVERT(bigint, VAS.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location,D.date)  AS AddedVassination
FROM PortFolioProject..[covid death] D
JOIN PortFolioProject..[covid vassination] VAS
ON D.date=VAS.date 
AND D.location=VAS.location
WHERE D.continent IS NOT NULL
--ORDER BY D.location,D.date


