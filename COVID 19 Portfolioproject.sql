
SELECT *
FROM PortfolioProject..CovidDeaths
order by 3,4 desc

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--Select Data we going to be using

SELECT location, date ,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at TotalCases vs TotalDeaths
-- Shows what percentage of population that died

SELECT location, date ,total_cases,total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Ghana%' -- Search for the death to cases ratio for your country
ORDER BY 1,2		

-- Looking at TotalCases vs Population
-- Shows what percentage of population got covid

SELECT location, date ,total_cases, (total_cases / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%Ghana%' -- Search for the death to cases ratio for your country
ORDER BY 1,2	

-- looking at Countries with Highest Infected Rate Compared to population

SELECT location, population, MAX(total_cases) AS HightesInfectionCount, MAX((total_cases) / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location  is not null  -- Search for the infected to cases ratio for your country
GROUP BY location , population
ORDER BY PercentPopulationInfected desc
  

  ---Showing Countries with Highest  Death PercentagePopulation
SELECT location, population , MAX(total_deaths) AS HightesInfectionCount, MAX((total_deaths) / population)* 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent  is not null  -- Search for the death to cases ratio for your countries only
GROUP BY location , population
ORDER BY 1,2


 ---Showing Countries with Highest  DeathCount per population

 SELECT location, MAX(CONVERT( int,total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent  is not null  -- Search for the death to cases ratio for your country
GROUP BY location 
ORDER BY TotalDeathCount desc

  --LETS BREAK THINGS DOWN BY CONTINENT 
   -- Showing  Continents the highest death per population

 SELECT continent , MAX(CONVERT( int,total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE location  is not null  -- Search for the death to cases ratio for your country
GROUP BY continent 
ORDER BY TotalDeathCount desc

--GLOBAL NUMBER OF CASES AND DEATHS

SELECT date ,SUM(new_cases)as TotalCases , SUM(CONVERT(int ,new_deaths)) , SUM(CONVERT(int, new_deaths))/ SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null -- Search for the death to cases ratio for your country
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases)as TotalCases , SUM(CONVERT(int ,new_deaths)) , SUM(CONVERT(int, new_deaths))/ SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null -- Search for the death to cases ratio for your country
--GROUP BY date
ORDER BY 1,2



 --Looking at the total  Population Vs Vaccinations
SELECT dea.continent , dea.location , dea.date, dea.population ,vac.new_vaccinations,
SUM(CONVERT (int ,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location , dea.date) 
AS RollingPeopleVaccinated --, (RollingPeopleVaccinated / population) * 100 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
	 WHERE dea.continent is not null
	 order by 1,2,3			
	 
	 --USING CTE

	 WITH PopVsVac (Continent , location ,Date , Population , New_Vaccinations, RollingPeopleVaccinated)
	 AS (
          SELECT dea.continent , dea.location , dea.date, dea.population ,vac.new_vaccinations,
SUM(CONVERT (int ,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location , dea.date) 
AS RollingPeopleVaccinated --, (RollingPeopleVaccinated / population) * 100 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
	 WHERE dea.continent is not null
	 --order by 1,2,3
	 )
	 SELECT * , (RollingPeopleVaccinated / population) * 100 
	 FROM PopVsVac

	 --USING TEMP TABLE
	 DROP TABLE IF EXISTS #PercentPopulationVaccinated
	 CREATE TABLE #PercentPopulationVaccinated
	 (
	 Continent nvarchar(255),
	 Location   nvarchar(255),
	 Date       datetime,
	 Population  numeric,
	 New_Vaccinations numeric,
	 RollingPeopleVaccinated numeric
	 )
	 INSERT INTO #PercentPopulationVaccinated
	  SELECT dea.continent , dea.location , dea.date, dea.population ,vac.new_vaccinations,
       SUM(CONVERT (int ,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location , dea.date) 
       AS RollingPeopleVaccinated --, (RollingPeopleVaccinated / population) * 100 
         FROM PortfolioProject..CovidDeaths dea
         JOIN PortfolioProject..CovidVaccinations vac
          ON dea.location = vac.location
	     AND dea.date = vac.date
	     WHERE dea.continent is not null
	 --order by 1,2,3

	    SELECT * , (RollingPeopleVaccinated / population) * 100 
	   FROM #PercentPopulationVaccinated


       --Creating View to store for  latter Visualizations

	   CREATE VIEW PercentPopulationVaccinated AS
	    SELECT dea.continent , dea.location , dea.date, dea.population ,vac.new_vaccinations,
       SUM(CONVERT (int ,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location , dea.date) 
       AS RollingPeopleVaccinated --, (RollingPeopleVaccinated / population) * 100 
         FROM PortfolioProject..CovidDeaths dea
         JOIN PortfolioProject..CovidVaccinations vac
          ON dea.location = vac.location
	     AND dea.date = vac.date
	     WHERE dea.continent is not null

		 SELECT *
		 FROM PercentPopulationVaccinated