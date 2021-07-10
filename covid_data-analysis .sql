select * 
from portfolio..coviddeaths
order by 3,4


--select * 
--from portfolio..covidvac
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from portfolio..coviddeaths
order by 1,2

--total cases and deaths comparison {percentage in united states}
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolio..coviddeaths
where location like '%united states%'
order by 1,2

--HIGHEST INFECTION RATE AROUND

select location, population, max(total_cases)as highinfectionrate, max((total_cases/population))*100 as pollutedpercentage
from portfolio..coviddeaths
group by location, population
order by pollutedpercentage desc

--TOTAL DEATHCOUNTS AS PER CONTINENT!!!
select continent, max(cast (total_deaths as int))as totaldeathcount 
from portfolio..coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc

--global new figures
select sum(new_cases)as totalnewcase, sum(cast (new_deaths as int))as totalnewdeath,sum(cast (new_deaths as int))/sum(new_cases)*100 as deathpercent
from portfolio..coviddeaths
where continent is not null
order by 1,2

--TO SHOW TOTAL POPULATION VS VACCINATION

with popvsvac(continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)--tested for adding percentage column at the end
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,new_vaccinations))Over
(partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated--mentioning specific atrributes of each datatable
from portfolio..coviddeaths dea
join portfolio..covidvac vac--join statement
   on dea.location = vac.location--merging similar datacolumns
   and dea.date = vac.date
where dea.continent is not null
)
select *,(rollingpeoplevaccinated/population)*100 as vaccinationpercentage
from popvsvac


-- creating table

create table #percentpopulationvaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated int
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,new_vaccinations))Over
(partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated--mentioning specific atrributes of each datatable
from portfolio..coviddeaths dea
join portfolio..covidvac vac--join statement
   on dea.location = vac.location--merging similar datacolumns
   and dea.date = vac.date
where dea.continent is not null

select *,(rollingpeoplevaccinated/population)*100 as vaccinationpercentage
from #percentpopulationvaccinated

-- create view to store data for visualisation on tableau on my next project

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,new_vaccinations))Over
(partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated--mentioning specific atrributes of each datatable
from portfolio..coviddeaths dea
join portfolio..covidvac vac--join statement
   on dea.location = vac.location--merging similar datacolumns
   and dea.date = vac.date
where dea.continent is not null

select * from percentpopulationvaccinated







