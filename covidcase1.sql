select * from coviddatabase..coviddeaths
where continent is not null
order by 3,4

--select * from coviddatabase..covid_vaccinations

select location, date, total_cases, new_cases, total_deaths, population
from coviddatabase..coviddeaths
where continent is not null
order by 1,2


--total cases VS total deaths
--percentage of deaths in India
select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from coviddatabase..coviddeaths
where location like '%india%'
and continent is not null
order by 1,2

--total cases VS population
--percentage of population who got covid in India

select location, date, total_cases, population, (cast(total_deaths as float)/cast(population as float))*100 as CovidPercentage
from coviddatabase..coviddeaths
where location like '%india%'
and continent is not null
order by 1,2

--Highest infection Rate

select location, population, Max(total_cases)as HighestInfection, MAX((cast(total_deaths as float)/cast(population as float)))*100 as InfectionRate
from coviddatabase..coviddeaths
where continent is not null
group  by location, population

order by InfectionRate desc

--Location wise deaths
select location, Max(cast(total_deaths as int))as Deaths
from coviddatabase..coviddeaths
where continent is not null
group  by location
order by Deaths desc


--Global Numbers
SELECT date, SUM(cast(new_cases_smoothed as float)) AS TotalNewCases, SUM(CAST(new_deaths_smoothed AS float)) AS TotalNewDeaths, 
    SUM(CAST(new_deaths_smoothed AS float)) / SUM(cast(new_cases_smoothed as float)) * 100 AS GlobalDeathPercentage
FROM coviddatabase..coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;


--Join two tables based on location and date
select *
from coviddatabase..coviddeaths dea
join coviddatabase..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


--Total population vs Vaccination 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location, dea.date) as TotalPeopleGettingVaccination
from coviddatabase..coviddeaths dea
join coviddatabase..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE A Common Table Expression (CTE) in SQL is a temporary result set that can be 
--referenced within a SELECT, INSERT, UPDATE, or DELETE statement. CTEs are defined using the WITH keyword 
--and allow you to create a named, reusable subquery within your SQL statement.

With PopulationVSVaccination(continent, location, date, population, new_vaccinations, TotalPeopleGettingVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location, dea.date) as TotalPeopleGettingVaccination
from coviddatabase..coviddeaths dea
join coviddatabase..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (TotalPeopleGettingVaccination/Population)*100 as PopulationVsVaccination
from PopulationVSVaccination

--Create View for visualisation

Create View PopulationVSVaccination as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location, dea.date) as TotalPeopleGettingVaccination
from coviddatabase..coviddeaths dea
join coviddatabase..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3