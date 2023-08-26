Select *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2


-- Looking ata Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%South Africa%'
ORDER BY 1,2


-- Looking at Total cases vs Population
-- Shows what percentage of population got covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%South Africa%'
ORDER BY 1,2


-- Lookingat countries with the highest infection rate

SELECT Location, population,MAX(total_cases) as HighestInfectionCount, 
	MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%South Africa%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- Showing countries with highest Death count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


-- Broken down by CONTINENT
-- Continents with the highest death countsx

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- GLOBAL Numbers

SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths,
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE location like '%South Africa%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Total Cases WorldWide per Day

SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths,
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE location like '%South Africa%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY 
	dea.location, dea.date) as RollingVaccineCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



-- Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccineCount)
as
(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY 
	dea.location, dea.date) as RollingVaccineCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *,(RollingVaccineCount/Population)*100
FROM PopvsVac



--TEMP TABLE
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccineCount numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY 
	dea.location, dea.date) as RollingVaccineCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

Select *,(RollingVaccineCount/Population)*100
FROM #PercentagePopulationVaccinated



-- Creating View for later visualisation

CREATE VIEW PercentagePeopleVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY 
	dea.location, dea.date) as RollingVaccineCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3