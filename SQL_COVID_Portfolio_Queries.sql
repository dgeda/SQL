


------ Preview CovidDeaths-----

SELECT *
FROM 
  Portfolio.CovidDeaths
ORDER BY 3,4
LIMIT 1000


---Preview CovidVaccinations----

SELECT *
FROM 
  Portfolio.CovidVaccinations
ORDER BY 3,4
LIMIT 1000

------------------------------------------------------------------
/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From 
  Portfolio.CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select 
  Location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population
From Portfolio.CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select 
  Location, date, total_cases,total_deaths, 
  (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio.CovidDeaths
Where location like '%States%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select 
  Location, date, Population, total_cases,  
  (total_cases/population)*100 as PercentPopulationInfected
From Portfolio.CovidDeaths
Where location like '%States%'
order by 1,2


-- Breaking Things Down by Country

-- Countries with Highest Infection Rate compared to Population

Select 
  Location, Population, MAX(total_cases) as HighestInfectionCount,  
  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio.CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select 
  Location, 
  MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio.CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
Order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select 
  continent, 
  MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio.CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
Order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select 
  SUM(new_cases) as total_cases, 
  SUM(cast(new_deaths as int)) as total_deaths, 
  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio.CovidDeaths
--Where location like '%states%'
Where continent is not null 
--Group By date
Order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine using windows fucntions

Select 
  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio.CovidDeaths dea
Join Portfolio.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
order by 2,3


-- Using CTE to perform a calcualtion based on our previous query

With PopvsVac as (
Select 
  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio.CovidDeaths dea
Join Portfolio.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
order by 2,3
)
Select 
  *, 
  (RollingPeopleVaccinated/population)*100 as PercentVaccinated
From PopvsVac


-- Instead of CTE we can alternatively use a temp table

Drop Table IF Exists Portfolio.PopulationVaccinated

Create Table Portfolio.PopulationVaccinated
(
Continent string,
Location string,
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into Portfolio.PopulationVaccinated
Select 
  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio.CovidDeaths dea
Join Portfolio.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
order by 2,3

Select 
  *, 
  (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From Portfolio.PopulationVaccinated 



-- Creating View to store data for later visualizations

Drop View IF Exists Portfolio.PercentPopulationVaccinated

Create View Portfolio.PercentPopulationVaccinated as
Select 
  *,
  (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From Portfolio.PopulationVaccinated 







