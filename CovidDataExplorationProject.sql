select * 
from PortfolioProject.dbo.CovidDeaths 
where continent is not null
order by 3,4

select * 
from PortfolioProject.dbo.CovidVaccinations 
order by 3,4

--select Data that we are going to be using

Select Location, date, total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at the total cases vs population

select Location, date, total_cases, population , (total_cases/population) * 100 as CasesPercentage 
from CovidDeaths
where location like '%states%'
order by 1,2

-- Countries with Highest Infection rate compared to population

select Location, MAX(total_cases) as HighestInfectionCount, population , MAX((total_cases/population)) * 100 as Percentageofpopuinfected 
from CovidDeaths
--where location like '%states%'
group by Location, population
order by Percentageofpopuinfected desc

--showing countries with highest death count per population
     
select location, MAX(cast(total_deaths as int)) as highesttotaldeath
--MAX((total_deaths/population)) as DeathCountPerPopulation
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location
order by highesttotaldeath desc


--LET`S BREAK THINGS DOWN BY CONTINENT
     
select location, MAX(cast(total_deaths as int)) as highesttotaldeath
from PortfolioProject.dbo.CovidDeaths
where continent is null
group by location
order by highesttotaldeath desc

--showing continents with highest death count per population

select continent, MAX(cast(total_deaths as int)) as highesttotaldeath
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by highesttotaldeath desc

--GLOBAL NUMBERS

Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int ))/sum(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Looking at total population vs Vaccinations
     
select dea.continent, dea.location,dea.date, dea.population,
vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations ))
OVER(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac 
     on dea.location = vac.location 
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3

     
--USE CTE

with PopvsVac (Continent, location, date, Population,new_vaccinations,RollingpeopleVaccinated) as 
(
select dea.continent, dea.location,dea.date, dea.population,
vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations ))
OVER(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac 
     on dea.location = vac.location 
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingpeopleVaccinated/population)*100
from PopvsVac



--Temp table

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeoplevaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population,
vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations ))
OVER(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac 
     on dea.location = vac.location 
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * , (RollingpeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualizations
     
Create View Percentpopulationvaccinated as
select dea.continent, dea.location,dea.date, dea.population,
vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations ))
OVER(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac 
     on dea.location = vac.location 
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * from
Percentpopulationvaccinated

