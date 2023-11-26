#creating table to show year to year analysis(scale) 
CREATE TABLE year_to_year_increase AS SELECT
    t1.year,
    t1.`CO2_emissio_ estimates`,
    t1.value,
    t2.value AS previous_emission,
    ROUND(((t1.value - t2.value) / t2.value) * 100,2) AS yoy_increase
FROM
    project1.carbon_dioxide_emission_estimates t1
JOIN
    project1.carbon_dioxide_emission_estimates t2 ON t1.year = t2.year + 10 AND t1.`CO2_emissio_ estimates` = t2.`CO2_emissio_ estimates`
 where t1.series = 'Emissions (thousand metric tons of carbon dioxide)'
    AND t2.series = 'Emissions (thousand metric tons of carbon dioxide)';

#calculating the average of co2 emission value
SELECT
    `CO2_emissio_ estimates`,
    round(AVG(value),2) AS avg_emission
FROM
    project1.carbon_dioxide_emission_estimates
WHERE
    series = 'Emissions (thousand metric tons of carbon dioxide)'
GROUP BY
    `CO2_emissio_ estimates`;
    
#calculating the correlation between co2 emission value and land
SELECT 
    l.Series,
    (
        COUNT(*) * SUM(c.value * l.value) - SUM(c.value) * SUM(l.value)
    ) / SQRT(
        (COUNT(*) * SUM(POW(c.value, 2)) - POW(SUM(c.value), 2)) * 
        (COUNT(*) * SUM(POW(l.value, 2)) - POW(SUM(l.value), 2))
    ) AS correlation_coefficient
FROM 
    project1.carbon_dioxide_emission_estimates c
INNER JOIN 
    project1.land l ON c.year = l.year
WHERE 
    l.land = 'Total, all countries or areas'
GROUP BY 
    l.Series;

#calculating the correlation between co2 emission value and water sanitation
SELECT 
    l.Series,
    (
        COUNT(*) * SUM(c.value * l.value) - SUM(c.value) * SUM(l.value)
    ) / SQRT(
        (COUNT(*) * SUM(POW(c.value, 2)) - POW(SUM(c.value), 2)) * 
        (COUNT(*) * SUM(POW(l.value, 2)) - POW(SUM(l.value), 2))
    ) AS correlation_coefficient
FROM 
    project1.carbon_dioxide_emission_estimates c
INNER JOIN 
    `project1`.`water and sanitation services` l ON c.year = l.year
WHERE 
    l.`Water supply and sanitation services` = 'Total, all countries or areas'
GROUP BY 
    l.Series;

#calculating the population based on per captia and total co2 emission  value and saving the data
CREATE TABLE estimated_population_table AS select `CO2_emissio_ estimates`,year,round((select value from project1.carbon_dioxide_emission_estimates where `CO2_emissio_ estimates`= e.`CO2_emissio_ estimates` and year = e.year and Series = 'Emissions (thousand metric tons of carbon dioxide)')*1000/(select value from project1.carbon_dioxide_emission_estimates where `CO2_emissio_ estimates`= e.`CO2_emissio_ estimates` and year = e.year and Series = 'Emissions per capita (metric tons of carbon dioxide)'),2) as population
from carbon_dioxide_emission_estimates e
group by `CO2_emissio_ estimates`,year;

#calculating the correlation between co2 emission value and population of estimated population
SELECT 
    c.`CO2_emissio_ estimates`,
    (
        COUNT(*) * SUM(c.value * p.population) - SUM(c.value) * SUM(p.population)
    ) / SQRT(
        (COUNT(*) * SUM(POW(c.value, 2)) - POW(SUM(c.value), 2)) * 
        (COUNT(*) * SUM(POW(p.population, 2)) - POW(SUM(p.population), 2))
    ) AS correlation_coefficient
FROM 
    carbon_dioxide_emission_estimates c
INNER JOIN 
    estimated_population_table p ON c.year = p.Year and c.`CO2_emissio_ estimates`= p.`CO2_emissio_ estimates`
WHERE 
    c.Series = 'Emissions (thousand metric tons of carbon dioxide)'
GROUP BY 
     c.`CO2_emissio_ estimates`;
