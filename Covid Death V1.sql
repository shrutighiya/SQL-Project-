SELECT * FROM portfolio_project.covidvaccinations;
-- Select the data that we are going to use
Select 
location, 
date, total_cases, 
new_cases, 
total_deaths, 
population
FROM 
	portfolio_project.coviddeath
ORDER BY 1;

-- Looking as total cases versus total deaths
-- shows likelihood of dying if you contract
SELECT location, date,total_cases,total_deaths, (total_deaths/total_cases) * 100 AS deathpercentage
from portfolio_project.coviddeath
WHERE location = "United States"
ORDER By date DESC;

-- looking at total cases vs population
-- shows what percentage of population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as covid_population
FROM portfolio_project.coviddeath
WHERE location = "United States"
ORDER BY 1;

-- looking conutries highest infection rate compared to population
SELECT location, population, max(total_cases) as highestinfection, MAX((total_cases/population)*100) as covid_population
FROM portfolio_project.coviddeath
GROUP BY location, population
ORDER BY covid_population DESC;

-- looking countries with highest death rate compared to population
SELECT location, max(CAST(total_deaths AS unsigned))  as totaldeathcount
FROM portfolio_project.coviddeath
WHERE continent is not null
GROUP BY location
ORDER BY totaldeathcount DESC;

-- let's break it by continent
SELECT continent, max(CAST(total_deaths AS unsigned))  as totaldeathcount
FROM portfolio_project.coviddeath
WHERE continent is not null
GROUP BY continent
ORDER BY totaldeathcount DESC;

-- Global Numbers
SELECT date, sum(new_cases) as Total_cases, SUM(CAST(new_deaths AS unsigned)) AS Total_deaths,(SUM(CAST(new_deaths AS unsigned))/SUM(new_cases))* 100 AS deathpercent
FROM portfolio_project.coviddeath
WHERE continent is not null
GROUP BY date
ORDER BY date ASC;




-- Looking at Total population vs Total vacination

SELECT
continent, location, date, population, new_vaccinations, RollingVaccinated/population * 100
FROM 
(SELECT death.continent,death.location, death.date, death.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as unsigned)) OVER (partition by death.location Order by death.location, death.date) as RollingVaccinated
FROM portfolio_project.coviddeath as death
JOIN portfolio_project.covidvaccinations as vac
ON death.location = vac.location
AND death.date = vac.date
WHERE death.continent is not null
ORDER BY 2,3) as roll;

-- creating view to store data for visualization

CREATE View percentpopulationvaccinated
AS SELECT
continent, location, date, population, new_vaccinations, RollingVaccinated/population * 100
FROM 
(SELECT death.continent,death.location, death.date, death.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as unsigned)) OVER (partition by death.location Order by death.location, death.date) as RollingVaccinated
FROM portfolio_project.coviddeath as death
JOIN portfolio_project.covidvaccinations as vac
ON death.location = vac.location
AND death.date = vac.date
WHERE death.continent is not null
ORDER BY 2,3) as roll;

SELECT * from percentpopulationvaccinated;

