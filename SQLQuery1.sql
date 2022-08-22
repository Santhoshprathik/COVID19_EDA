--Covid19 deaths analysis

--complete table
select * from covid19..CDeaths 
order by 3,4

--total cases vs total deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from covid19..CDeaths
where location like '%india%'
order by 1,2

--total cases vs population

select location,date,total_cases,population,(total_cases/population)*100 as casesRate
from covid19..CDeaths

order by 1,2

--country with heighest infection rate

select location,max(total_cases) as maxcases,population,max((total_cases/population)*100 )as infectionaRate
from covid19..CDeaths
where location like '%india%'
group by location, population
order by 4 desc

-- death count in the continent

select continent, sum(population) as c1, sum( total_cases ) as c2, sum(cast (total_deaths as int))
from covid19..CDeaths
where continent is not null
group by continent


--total vaccinations vs population

select de.continent, de.location, de.date, de.population, vc.new_vaccinations, 
sum( cast(vc.new_vaccinations as int)) over (partition by de.location order by de.location, de.date) as total_v
--  ,( sum( cast(vc.new_vaccinations as int)) over (partition by de.location order by de.location, de.date) /population)*100 as vaccination_percentage
from covid19..CDeaths de
join covid19.dbo.CVac vc
on de.location=vc.location
and de.date=vc.date
--where de.continent is not null and de.location like 'india'
order by 2,3

--with CTE

with neww (continent, location, date, population, new_vaccinations, total_v)
as 
(
select de.continent, de.location, de.date, de.population, vc.new_vaccinations, 
sum( cast(vc.new_vaccinations as int)) over (partition by de.location order by de.location, de.date) as total_v
--  ,( sum( cast(vc.new_vaccinations as int)) over (partition by de.location order by de.location, de.date) /population)*100 as vaccination_percentage
from covid19..CDeaths de
join covid19.dbo.CVac vc
on de.location=vc.location
and de.date= vc.date
where de.continent is not null 
--order by 2,3
)

select *
from neww

--create new table

create table percent_vaccinated_table
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumilative_vacc numeric
)

insert into percent_vaccinated_table

select de.continent, de.location, de.date, de.population, vc.new_vaccinations, 
sum( cast(vc.new_vaccinations as int)) over (partition by de.location order by de.location, de.date) as total_v
--  ,( sum( cast(vc.new_vaccinations as int)) over (partition by de.location order by de.location, de.date) /population)*100 as vaccination_percentage
from covid19..CDeaths de
join covid19.dbo.CVac vc
on de.location=vc.location
and de.date= vc.date
where de.continent is not null 
order by 2,3

select *
from percent_vaccinated_table

--create view to store data

create view percent_vaccinated as

select de.continent, de.location, de.date, de.population, vc.new_vaccinations, 
sum( cast(vc.new_vaccinations as int)) over (partition by de.location order by de.location, de.date) as total_v
--  ,( sum( cast(vc.new_vaccinations as int)) over (partition by de.location order by de.location, de.date) /population)*100 as vaccination_percentage
from covid19..CDeaths de
join covid19.dbo.CVac vc
on de.location=vc.location
and de.date= vc.date
where de.continent is not null 
--order by 2,3

select* 
from percent_vaccinated


--tableau queries

-- cases vs deaths // whole world

select sum( new_cases) as total_cases,sum (convert(int,new_deaths)) as total_deaths,(sum (convert(int,new_deaths)) / sum( new_cases) )*100 as deathPercentage
from covid19..CDeaths
where continent is not null

--total death count, continent wise

select location, sum(convert(int,new_deaths)) as total_death_count
from covid19..CDeaths
where continent is null and location not in ('world','European Union','International')
group by location
order by 2 desc

--country wise location vs population infected

select location, population, sum(new_cases) as total_cases, (sum(new_cases)/population)*100 as infection_rate
from covid19..CDeaths
where continent is not null
group by location, population
order by 4 desc

--avg infection rate vs country vs date

select location,date, population, max( total_cases) as people_infected, (max(total_cases)/population)*100 as infection_rate
from covid19..CDeaths
where continent is not null
group by location, population, date
order by 5 desc 


