select*
from ProjectPortfolio..CovidDeaths
Where continent is not null
order by 3,4

--select*
--from ProjectPortfolio..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From ProjectPortfolio..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths

-- Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (CAST(total_deaths AS decimal) / CAST(total_cases AS decimal)) * 100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where continent is not null
and Location like '%Nigeria%'
order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (CAST(total_cases AS decimal) / CAST(population AS decimal)) * 100 as PercentPopulationInfection
From ProjectPortfolio..CovidDeaths
Where location like '%Nigeria%'
and continent is not null
Order by 1,2

-- Countries with the Higest Infection Rate Compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/MAX(Population)) * 100 as PercentagePopulationInfected
From ProjectPortfolio..CovidDeaths
--Where location like '%Nigeria%'
Where continent is not null
Group by Location, Population
Order by PercentagePopulationInfected desc

-- Showing Countries With Highest Death Count per Population

Select Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
Where continent is not null
--and Location like '%Nigeria%
Group by Location
Order By TotalDeathCount desc

-- Let's break things down by Continent.

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
Where continent is not null
--and Location like '%Nigeria%
Group by Continent
Order By TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualiztion.

USE ProjectPortfolio
GO
Create View PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *
From PercentagePopulationVaccinated