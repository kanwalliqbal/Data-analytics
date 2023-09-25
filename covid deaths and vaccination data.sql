select * from CovidDeaths where continent is not null order by 3,4

select * from CovidVaccinations order by 1,7

select Location, date,total_cases, new_cases,total_deaths,population
from CovidDeaths order by 1,2

--Looking at Total Cases vs Total Deaths

select Location, date,total_cases, new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where Location like '%Pakistan%' and continent is not null
order by 1,2

--Looking at Total Cases vs Population
select Location, date,total_cases,population, (total_cases/population)*100 as DeathPercentage
from CovidDeaths
where Location like '%Pakistan%' and  continent is not null
order by 1,2

--Looking at the countries with highest infection rate
select Location, MAX(total_cases) as HighestInfectionRate ,population,MAX ((total_cases/population))*100 as DeathPercentage
From CovidDeaths
Group By Location,population
order by DeathPercentage desc

--Showing the countries with highest Death count per population

select Location, MAX(cast(total_deaths as int)) as HighestDeathCount
From CovidDeaths
where continent is not null
Group By Location
order by HighestDeathCount desc

--Break things down by continent
--Showing continents with highest death count per population

select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
From CovidDeaths
where continent is not null
Group By continent
order by HighestDeathCount desc


--Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--QTXbzcEywf
--Looking at total population vs Vaccinations

Select dea.continent, dea.location,dea.population,dea.date, vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) 
Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea join CovidVaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3



--USING CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
Drop Table if exists #percentpopulationVaccinated
create table #percentpopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric)
insert into  #percentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100
From #percentpopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated