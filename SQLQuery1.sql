SELECT * FROM CovidPortfolio..CovidDeaths
ORDER BY 3,4;
--SELECT * FROM CovidPortfolio..CovidVaccinations
--ORDER BY 3,4;

-- select data that we are going to use
SELECT location,date,total_cases,new_cases,total_deaths,population
from CovidPortfolio.dbo.CovidDeaths
order by 1,2;
-- looking at total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidPortfolio..CovidDeaths
order by 1,2;
-- looking at total cases vs population
select location,date,total_cases,population,(total_cases/population)*100 as CasesPercentageOverPopulation
from CovidPortfolio..CovidDeaths
--where location like '%state%'
order by 1,2;
--looking at coutries with highest infection rate compared to population
select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as CasesPercentageOverPopulation
from CovidPortfolio..CovidDeaths
group by location,population
order by 4 desc;
--looking at coutries with highest death count per population 
select location,max(cast(total_deaths as int)) as totaldeathcount
from CovidPortfolio..CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc;
--looking at continent with highest death count per population 
select continent,max(cast(total_deaths as int)) as totaldeathcount
from CovidPortfolio..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc;
--global numbers
select sum(new_cases) as totalcases,sum(cast (new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from CovidPortfolio..CovidDeaths
where continent is not null;
--looking total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as rollingcountofnewvac
 from CovidPortfolio.DBO.CovidVaccinations vac
join CovidPortfolio.dbo.CovidDeaths dea
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null
order by 2,3;
--use CTE
with popvsvac as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as rollingcountofnewvac
 from CovidPortfolio.DBO.CovidVaccinations vac
join CovidPortfolio.dbo.CovidDeaths dea
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null
--order by 2,3
)
select continent,location,date,population,new_vaccinations,rollingcountofnewvac,rollingcountofnewvac/population*100
from popvsvac;
--temp table
drop table if exists #percentpopulationvac
create table #percentpopulationvac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingcountofnewvac numeric
)
insert into #percentpopulationvac
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as rollingcountofnewvac
 from CovidPortfolio.DBO.CovidVaccinations vac
join CovidPortfolio.dbo.CovidDeaths dea
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null
order by 2,3

select *,rollingcountofnewvac/population*100
from #percentpopulationvac
--creating view to store data for later visualizations
create view percentpopulationvac as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as rollingcountofnewvac
 from CovidPortfolio.DBO.CovidVaccinations vac
join CovidPortfolio.dbo.CovidDeaths dea
on vac.location=dea.location
and vac.date=dea.date
where dea.continent is not null
--order by 2,3
select * from percentpopulationvac

