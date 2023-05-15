--select * from CovidDeaths
--order by 3,4

--select data we are going to use:

--Select Location, date, total_cases, new_cases, total_deaths, population
--from CovidDeaths
--order by 1,2

-- Looking at toal cases VS total deaths and likelihood of dying in selected country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like'%Greece%'
order by 1,2

--Looking at the total cases VS the poupulation. Shows the the % of population that got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from CovidDeaths
where location like'%Greece%'
order by 1,2

--coutnries with highest infection rate compared to population
Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100
as PercentPopulationInfected
from CovidDeaths
group by location, population
order by PercentPopulationInfected desc

--showing the countries with highest death count per population (cast method changes the type of the data, i.e. from charvar to int)
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Shows results by continent
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing cotninents with the highest death count per population
Select continent, population, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent 
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date, SUM(new_cases), SUM(cast (new_deaths as int)), SUM(cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not NULL
Group by date
order by 1,2

-- Looking the total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) 
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Use common table expression (CTE) for manipulating newly formed columns like rollingpoeplevaccinated

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating View to store dat for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
