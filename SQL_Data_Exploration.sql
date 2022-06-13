select * from portfolioproject..CovidDeaths
order by  3, 4;

-- this is the data that we are going to work on(taking out the columns that are most required to write queries)

select location, date , total_cases, new_cases, total_deaths, population 
from portfolioproject..CovidDeaths
order by 1,2;

--Let us start looking at total cases vs deaths.
--shows likelihood of dying in the data with location having states mentioned in it.

select location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPerc
from portfolioproject..CovidDeaths
where location like '%states%'
order by 1,2;

--Let us start looking at total cases vs population.
-- shows percentage of population got covid in india on daily basis.

select location, date , population, total_cases,  (total_cases/population)*100 as covidPositivePerc
from portfolioproject..CovidDeaths
where location like 'india'
order by 1,2;

--looking at the countries with highest infection rate compared to population.

select location, population, max(total_cases) as maxInfectedCount,  max((total_cases/population))*100 as maxcovidPositivePerc
from portfolioproject..CovidDeaths
group by location, population
order by maxcovidPositivePerc desc;

-- countries with highest death count per population

select location, max(cast(total_deaths as int)) as maxDeathCount
from portfolioproject..CovidDeaths
where continent is not null
group by location
--having location = 'india'
order by maxDeathCount desc;

--breaking down things by continent
-- continent with highest death count per population.


select continent, max(cast(total_deaths as int)) as maxDeathCount
from portfolioproject..CovidDeaths
where continent is not null
group by continent
--having location = 'india'
order by maxDeathCount desc;

--global numbers

select  sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPerc
from portfolioproject..CovidDeaths
where continent is not null
--group by date
--having location = 'india'
order by 1,2;


--total population vs vaccination

select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(convert(int, v.new_vaccinations))
over (partition by d.location order by d.location, d.date) as rollingVaccinated
from portfolioproject..CovidDeaths as d join portfolioproject..Covidvaccinations as v 
on  d.location = v.location and d.date =v.date
where d.continent is not null
order by 2,3;

-- use CTE

with population_vs_vaccination (continent, location, date, population, new_vaccinations, rollingVaccinated) as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(convert(int, v.new_vaccinations))
over (partition by d.location order by d.location, d.date) as rollingVaccinated
from portfolioproject..CovidDeaths as d join portfolioproject..Covidvaccinations as v 
on  d.location = v.location and d.date =v.date
where d.continent is not null
)
select *, (rollingVaccinated/population)*100 as vaccinatedPerc from population_vs_vaccination


--TEMP table 

drop table if exists temp_table
create table temp_table
(continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingVaccinated numeric)


insert into temp_table
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(convert(int, v.new_vaccinations))
over (partition by d.location order by d.location, d.date) as rollingVaccinated
from portfolioproject..CovidDeaths as d join portfolioproject..Covidvaccinations as v 
on  d.location = v.location and d.date =v.date
--where d.continent is not null

select *, (rollingVaccinated/population)*100 as vaccinatedPerc from temp_table


--create a view to store data for later visualization

create view percvaccinated as 
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(convert(int, v.new_vaccinations))
over (partition by d.location order by d.location, d.date) as rollingVaccinated
from portfolioproject..CovidDeaths as d join portfolioproject..Covidvaccinations as v 
on  d.location = v.location and d.date =v.date
where d.continent is not null


select * from percvaccinated
