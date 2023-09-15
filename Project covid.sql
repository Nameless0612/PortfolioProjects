select *
from PortfolioProject..CovidDeaths
order by 3, 4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3, 4

--select data to use

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at total cases vs total deaths
-- Death porcentage 

select Location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as Death_percentage
from PortfolioProject..CovidDeaths
where location like '%states'
and continent is Not null
order by 1, 2

-- Looking at Total Cases vs Population
-- Percentage with covid

select Location, date, total_cases, population, ((total_cases/population)*100) as Infection_percentage
from PortfolioProject..CovidDeaths
--where location like '%states'
where continent is Not null
order by 1, 2



-- Countries with Highest infection rates

select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(((total_cases/population))*100) as 
Percent_of_population_infected
from PortfolioProject..CovidDeaths
--where location like '%states'
where continent is Not null
Group by Location, Population
order by Percent_of_population_infected desc



-- Countries with highest death count

select Location, MAX(cast (Total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is Not null
Group by Location
order by TotalDeathCount desc

-- Continents with highest death rate

select Location, MAX(cast (Total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
Group by Location
order by TotalDeathCount desc




-- Global numbers

select 
--date, 
sum(new_cases) as TotalCases, 
sum(cast(new_deaths as int)) as TotalDeaths, 
((sum(cast(new_deaths as int))/sum(new_cases))*100) as Death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2


-- Total population vs vaccinations

-- CTE

with PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinationsAtDate)

as
(
select death.continent, death.location, death.date, 
death.population, vac.new_vaccinations,
sum(convert (bigint,vac.new_vaccinations)) 
over (partition by death.location order by death.location, death.date) as TotalVaccinationsAtDate
--,(TotalVaccinationsAtDate/death.location)*100
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location 
	and death.date = vac.date
where death.continent is not null
--order by 2, 3
)

select *,(TotalVaccinationsAtDate/population)*100 as percentage_vaccinated
from PopvsVac
order by 2,3


-- Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location  nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVaccinationsAtDate numeric
)

Insert into #PercentPopulationVaccinated
select death.continent, death.location, death.date, 
death.population, vac.new_vaccinations,
sum(convert (bigint,vac.new_vaccinations)) 
over (partition by death.location order by death.location, death.date) as TotalVaccinationsAtDate
--,(TotalVaccinationsAtDate/death.location)*100
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location 
	and death.date = vac.date
--where death.continent is not null
--order by 2, 3

select *,(TotalVaccinationsAtDate/population)*100 as percentage_vaccinated
from #PercentPopulationVaccinated
order by 2,3


--views for later visualization

create view PercentPopulationVaccinated as

 select death.continent, death.location, death.date, 
death.population, vac.new_vaccinations,
sum(convert (bigint,vac.new_vaccinations)) 
over (partition by death.location order by death.location, death.date) as TotalVaccinationsAtDate
--,(TotalVaccinationsAtDate/death.location)*100
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location 
	and death.date = vac.date
where death.continent is not null
--order by 2, 3



