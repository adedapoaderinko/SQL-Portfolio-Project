/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From ..CovidDeaths_1
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From ..CovidDeaths_1
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ..CovidDeaths_1
Where location like '%Nigeria%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From ..CovidDeaths_1
--Where location like '%Nigeria%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From ..CovidDeaths_1
--Where location like '%Nigeria%'
Group by Location, population
order by PercentPopulationInfected desc

--Showing the country with the highest death counts per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathcounts
From ..CovidDeaths_1
--Where location like '%Nigeria%'
Where continent is not null 
Group by Location 
order by TotalDeathcounts desc


--Let break things down by Continent

Select continent, MAX(total_deaths) as TotalDeathcounts
From ..CovidDeaths_1
--Where location like '%Nigeria%'
Where continent is not null 
Group by continent 
order by TotalDeathcounts desc

--Showing the continents with highest death counts per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathcounts
From ..CovidDeaths_1
--Where location like '%Nigeria%'
Where continent is not null 
Group by continent 
order by TotalDeathcounts desc


-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ..CovidDeaths_1
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ..CovidDeaths_1 dea
Join ..CovidVaccinations_1 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Using CTE


WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
    FROM ..CovidDeaths_1 dea
    JOIN ..CovidVaccinations_1 vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL 
)
SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM PopvsVac;


-- Creating viw to store data for later visualization

CREATE View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ..CovidDeaths_1 dea
Join ..CovidVaccinations_1 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *
From PercentagePopulationVaccinated