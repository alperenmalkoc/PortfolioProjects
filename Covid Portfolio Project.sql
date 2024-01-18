select * from PortfolioProject..CovidDeaths
order by 3,4


Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2

--Toplam Vaka ve Popülasyona Bakýþ
Select location,date,total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like '%states%'
order by 1,2

--Nüfüsa Kýyasla Enfeksiyon Kapma Oranýnýn En Yüksek Olduðu Ülke
Select location,population,MAX(total_cases) as HighesInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
--where location like '%states%'
group by location , population
order by PercentPopulationInfected desc


--Nüfüs Baþýna En Yüksek Ölüm Sayýsý
Select location,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount   desc


--Kýtalar Göre Ölüm Sayýsý
Select continent,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by continent desc


--Global 
Select date,sum(new_cases) as TotalCases , sum(cast(new_deaths as int)) as TotalDeaths , sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date 
order by 1 ,2 

--Join 
-- Popülasyon ve Aþýlanma
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVac
--(RollingPeopleVac/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--Tablo Oluþturma 
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVac numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVac
--(RollingPeopleVac/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3;


--Görselleþtirme Ýçin Veri Oluþturma

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVac
--(RollingPeopleVac/population)*100
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3;

Select * from PercentPopulationVaccinated