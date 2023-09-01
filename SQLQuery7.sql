select * 
from Portfolio..CovidDeaths$
where continent is not null 
order by 3,4
 
--select * 
--from Portfolio..CovidVaccinations$
--order by 3,4

--Select Location, date, total_cases, new_cases, total_deaths, population
--From Portfolio..CovidDeaths$
--order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country 

SELECT
    Location,
    Date,
    Total_Cases,
    Total_Deaths,
    CASE
        WHEN TRY_CAST(Total_Cases AS FLOAT) IS NULL OR TRY_CAST(Total_Cases AS FLOAT) = 0 THEN 0
        ELSE TRY_CAST(Total_Deaths AS FLOAT) / TRY_CAST(Total_Cases AS FLOAT) * 100
    END AS Death_Ratio
FROM
    Portfolio..CovidDeaths$
--Where location like '%israel' 
  where continent is not null 
ORDER BY
   1,2;

--looking at total cases vs Population
--shows precentage of population with covid 

SELECT
    Location,
    Date,
	Population,
    Total_Cases,
    Total_Deaths,
    CASE
        WHEN TRY_CAST(Total_Cases AS FLOAT) IS NULL OR TRY_CAST(Total_Cases AS FLOAT) = 0 THEN 0
        ELSE TRY_CAST(Total_Cases AS FLOAT) / TRY_CAST(Population AS FLOAT) * 100
    END AS Population_Precentage 
FROM
    Portfolio..CovidDeaths$
--Where location like '%israel'
where continent is not null 
ORDER BY
    1,2;

--Looking at countries with the Highest Infection compard to Population 

SELECT
    Location,
    Population,
    MAX(total_cases) AS HighestInfectionCount,
    (CAST(MAX(total_cases) AS FLOAT) / Population) * 100 AS HighestPercentage
FROM
    Portfolio..CovidDeaths$
	where continent is not null 
GROUP BY
    Population, Location
ORDER BY
    HighestPercentage desc;


SELECT
    location,
    MAX(CAST(Total_Deaths AS BIGINT)) AS TotalDeathCount
FROM
    Portfolio..CovidDeaths$
WHERE
    Continent IS NULL
    --AND Continent NOT LIKE '%High income%'
    --AND Continent NOT LIKE '%Upper middle income%'
    --AND Continent NOT LIKE '%lower middle income%'
    --AND Continent NOT LIKE '%low income%'
GROUP BY
    location
ORDER BY
    TotalDeathCount DESC;


--Showing Countries with Highest death Count oer Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio..CovidDeaths$
where continent is not null 
group by location 
order by TotalDeathCount desc

--GLOBAL NUMBERS

SELECT
   -- Date,
    SUM(new_cases) AS TotalNewCases,
    SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths,
    (SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(new_cases), 0)) * 100 AS DeathPercentage
FROM
    Portfolio..CovidDeaths$
WHERE
    Continent IS NOT NULL
ORDER BY
1,2;


--Looking at Total Population vs Vaccinations
--USE CTE 
-- Create the Common Table Expression (CTE)

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(
    SELECT
        dea.Continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM
        Portfolio..CovidDeaths$ AS dea
    JOIN
        Portfolio..CovidVaccinations$ AS vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE
        dea.Continent IS NOT NULL
)
 Select *, (RollingPeopleVaccinated/population)*100 
 From PopvsVac

-- Create the temporary table
-- Drop the temporary table if it exists
--TEMP TABLE

 DROP Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric 
 )

 
Insert into #PercentPopulationVaccinated
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from Portfolio..CovidDeaths$ dea
 join Portfolio..CovidVaccinations$ vac 
  on dea.location = vac.location 
  and dea.date = vac.date
--where dea.Continent IS NOT NULL
--order by 2,3

 Select *, (RollingPeopleVaccinated/population)*100 
 From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View VacPercentPopulationVaccinated as 
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 from Portfolio..CovidDeaths$ dea
 join Portfolio..CovidVaccinations$ vac 
  on dea.location = vac.location 
  and dea.date = vac.date
where dea.Continent IS NOT NULL



Select *
From vacPercentPopulationVaccinated