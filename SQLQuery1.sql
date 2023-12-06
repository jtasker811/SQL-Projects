--SELECT * FROM [Portfolio Project 1]..CovidDeaths
--ORDER BY 3,4

--SELECT * FROM [Portfolio Project 1]..CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to be using

--SELECT location, date, total_cases, new_cases, total_deaths, population FROM [Portfolio Project 1]..CovidDeaths
--ORDER BY 1,2

--Look at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project 1]..CovidDeaths
WHERE location like '%United Kingdom%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectionPercentage
FROM [Portfolio Project 1]..CovidDeaths
WHERE location like '%United Kingdom%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionPercentage
FROM [Portfolio Project 1]..CovidDeaths
GROUP BY location, population
ORDER BY InfectionPercentage desc

--Show countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project 1]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Breakdown by continent
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project 1]..CovidDeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project 1]..CovidDeaths
WHERE continent IS  NOT NULL
ORDER BY 1,2

--JOIN
SELECT * from [Portfolio Project 1]..CovidDeaths dea
JOIN [Portfolio Project 1]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project 1]..CovidDeaths dea
JOIN [Portfolio Project 1]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project 1]..CovidDeaths dea
JOIN [Portfolio Project 1]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)
SELECT * FROM PopvsVac

--Create table
DROP TABLE IF EXISTS #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project 1]..CovidDeaths dea
JOIN [Portfolio Project 1]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopVaccinated

-- Creating view to store data for later visualizations

CREATE VIEW PercentPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project 1]..CovidDeaths dea
JOIN [Portfolio Project 1]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL