
select *
from [CovidDeath&Vaccination].dbo.CovidDeaths
where continent is not null
order by 3,4

--select *
--from [CovidDeath&Vaccination].dbo.CovidVaccine
--order by 3,4

select location,date,total_cases,new_cases,total_deaths
from [CovidDeath&Vaccination].dbo.CovidDeaths
order by 1,2


--Total Cases vs Total Deaths

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [CovidDeath&Vaccination].dbo.CovidDeaths
where location='India'
order by DeathPercentage Desc

--Total cases vs Population

select location,date,population,total_cases, (total_cases/population)*100 as Percentage
from [CovidDeath&Vaccination].dbo.CovidDeaths
where location='India'
order by Percentage Desc


--country has Highest infection rate


select location,population,max(total_cases) as HighestInfection, max(total_cases/population)*100 as Percentage
from [CovidDeath&Vaccination].dbo.CovidDeaths
--where location='India'
Group by location,population
order by Percentage desc


--Countries with highest death count per population

select location,max(cast(total_deaths as int)) as TotalDeathCount
from [CovidDeath&Vaccination].dbo.CovidDeaths
--where location='India'
where continent is not null
Group by location
order by TotalDeathCount desc


--by continent
--continent with highest death count


select continent,max(cast(total_deaths as int)) as TotalDeathCount
from [CovidDeath&Vaccination].dbo.CovidDeaths
--where location='India'
where continent is not null
Group by continent
order by TotalDeathCount desc



--global nos by date

select date,sum(new_cases) as GlobalNewCases, sum(cast(new_deaths as int)) as GlobalNewDeaths, (sum(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from [CovidDeath&Vaccination].dbo.CovidDeaths
where continent is not null
group by date
order by 1,2


--global nos


select sum(new_cases) as GlobalNewCases, sum(cast(new_deaths as int)) as GlobalNewDeaths, (sum(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from [CovidDeath&Vaccination].dbo.CovidDeaths
where continent is not null
--group by date
order by 1,2


--vaccination table

select *
from [CovidDeath&Vaccination].dbo.CovidDeaths as dea
join [CovidDeath&Vaccination].dbo.CovidVaccine as vac
	on dea.location=vac.location
	and dea.date=vac.date


--Total population vs Total vaccination

with PopvsVac(continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [CovidDeath&Vaccination].dbo.CovidDeaths as dea
join [CovidDeath&Vaccination].dbo.CovidVaccine as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--Temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [CovidDeath&Vaccination].dbo.CovidDeaths as dea
join [CovidDeath&Vaccination].dbo.CovidVaccine as vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--creating view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [CovidDeath&Vaccination].dbo.CovidDeaths as dea
join [CovidDeath&Vaccination].dbo.CovidVaccine as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3



select *
from PercentPopulationVaccinated