select*
from CovidDeaths
where continent is not null
order by 3,4

select*
from CovidVaccinations
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from CovidDeaths
where location like '%states'
and continent is not null
order by 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as percentageofpopgotcovid
from CovidDeaths
where location like '%states'
and continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as Highestinfectioncount, max((total_cases/population))*100 as percentageofpopgotcovid
from CovidDeaths
where continent is not null
--where location like '%states'
group by location, population
order by percentageofpopgotcovid desc

-- Showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as totaldeathcount 
from CovidDeaths
--where location like '%states'
where continent is not null
group by location
order by totaldeathcount desc

-- Lets break things down by continent

-- Showing continent with the highest deathcount

select continent, MAX(cast(total_deaths as int)) as totaldeathcount 
from CovidDeaths
--where location like '%states'
where continent is not null
group by continent
order by totaldeathcount desc

-- Global Numbers

select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

--Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevac
--, (rollingpeoplevac/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use cte

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevac)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevac
--, (rollingpeoplevac/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevac/population)*100
from popvsvac

--temp table

drop table if exists #percentpopvac
create table #percentpopvac
(
continent varchar(100),
location varchar(100),
date datetime,
population int,
new_vaccinations int,
rollingpeoplevac int)

insert into #percentpopvac
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevac
--, (rollingpeoplevac/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

select*, (rollingpeoplevac/population)*100
from #percentpopvac


--createing view to store date for later visulaization

create view Percentpopulationvac as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevac
--, (rollingpeoplevac/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

