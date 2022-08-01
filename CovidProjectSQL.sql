SELECT * 
FROM CovidProject..CovidDeaths$
order by 3,4

--SELECT * 
--FROM CovidProject..CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths$
order by 1,2

-- So we see at the first example of Afghanistan, cases tend to ramp up as time goes on after the first confirmed case

-- Looking at Total cases vs Total deaths
-- Shows the likelyhood of dying if you get COVID in countries 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths$
WHERE location like '%Turkey%'
order by 1,2

-- Looking at Total cases vs Population
-- shows the percantage of population got COVID
Select Location, date, total_cases, Population, (total_cases/population)*100 as InfectionPercentage
FROM CovidProject..CovidDeaths$
WHERE location like '%Turkey%'
order by 1,2

-- Looking at Countries with highest infection rate compared to their population in descending order

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
FROM CovidProject..CovidDeaths$
--WHERE location like '%Turkey%'
group by Location,population
order by InfectionPercentage DESC

-- Showing the countries with highest Death count per Population

-- So total_deaths data type is Nvarchar for some reason, so we need to change it with CAST

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount 
FROM CovidProject..CovidDeaths$
--WHERE location like '%Turkey%'
group by Location
order by TotalDeathCount  DESC
-- the data also includes Continents so for more accurate representation, we can add a line such as (WHERE continent is not null)

-- Showing continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
FROM CovidProject..CovidDeaths$
--WHERE location like '%Turkey%'
WHERE continent is not null
group by continent
order by TotalDeathCount  DESC

-- Global stats

Select date, SUM(new_cases), SUM(CAST(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths$
--WHERE location like '%Turkey%'
where continent is not null
Group by date
order by 1,2

-- total deaths

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths$
--WHERE location like '%Turkey%'
where continent is not null
--Group by date
order by 1,2

-- VACCINATIONS

-- Looking at Total Population  vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   order by 2,3


   
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as (

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(CONVERT(int,vac.new_vaccinations))
OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   --order by 2,3
   )
   SELECT *, (RollingPeopleVaccinated/Population)*100
   From PopvsVac
   

--Create view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(CONVERT(int,vac.new_vaccinations))
OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   --order by 2,3

