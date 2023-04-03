select * 
from PortProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortProject..CovidVaccinations
--order by 3,4

--select data we're using

select location, date, total_cases, new_cases, total_deaths, population
from PortProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you get covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortProject..CovidDeaths
where location like '%israel%' and continent is not null
order by 1,2

--looking at total_cases vs. pop.
--shows percentage of pop. got covid

select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
from PortProject..CovidDeaths
where location like '%israel%' and continent is not null
order by 1,2

--what country has the highest infection rate versus pop.

select location, population, max(total_cases)as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected  
from PortProject..CovidDeaths
--where location like '%israel%'
where continent is not null
group by Location, Population
order by PercentPopulationInfected desc


select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortProject..CovidDeaths
--where location like '%israel%'
where continent is not null
group by Location
order by TotalDeathCount desc

--show continents with highest death count

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortProject..CovidDeaths
--where location like '%israel%'
where continent is not null
group by Location
order by TotalDeathCount desc

--global

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortProject..CovidDeaths
where continent is not null
group by date 
order by 1,2

--looking at total population vs vax 

select *
from PortProject..CovidDeaths dea
join PortProject..CovidVaccinations vax
	on dea.location = vax.location
	and dea.date = vax.date 

select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
 SUM(cast(vax.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
 as RollingSumVaccinations
 --, (RollingSumVaccinations/population)*100 
from PortProject..CovidDeaths dea
join PortProject..CovidVaccinations vax
	on dea.location = vax.location
	and dea.date = vax.date 
where dea.continent is not null
order by 2,3

--USE CTE

with PopulationVSVaccination (continent, location, date, population, new_vaccinations, RollingSumVaccinations)
as 
 (
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
 SUM(cast(vax.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
 as RollingSumVaccinations
 --, (RollingSumVaccinations/population)*100 
from PortProject..CovidDeaths dea
join PortProject..CovidVaccinations vax
	on dea.location = vax.location
	and dea.date = vax.date 
where dea.continent is not null
--order by 2,3
)
select *, (RollingSumVaccinations/Population)*100
from PopulationVSVaccination

--TEMP TABLE

DROP table if exists #PercentPopulationVaxxed
Create Table #PercentPopulationVaxxed
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingSumVaccinations numeric
)

INSERT into #PercentPopulationVaxxed
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
 SUM(cast(vax.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
 as RollingSumVaccinations
 --, (RollingSumVaccinations/population)*100 
from PortProject..CovidDeaths dea
join PortProject..CovidVaccinations vax
	on dea.location = vax.location
	and dea.date = vax.date 
--where dea.continent is not null
--order by 2,3

select *, (RollingSumVaccinations/Population)*100
from #PercentPopulationVaxxed

--Creating view to store date for visualization

Create View PercentPopulationVaxxed as 
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
 SUM(cast(vax.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) 
 as RollingSumVaccinations
 --, (RollingSumVaccinations/population)*100 
from PortProject..CovidDeaths dea
join PortProject..CovidVaccinations vax
	on dea.location = vax.location
	and dea.date = vax.date 
where dea.continent is not null
--order by 2,3






