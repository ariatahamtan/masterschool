DROP VIEW forestation;
CREATE VIEW forestation
As
(SELECT f.country_code, 
f.year,
f.forest_area_sqkm,
l.country_name,
l.total_area_sq_mi,
r.region,
r.income_group,
l.total_area_sq_mi * 2.59 as total_area_sqkm,
f.forest_area_sqkm /(l.total_area_sq_mi * 2.59) perc
FROM forest_area f
join land_area l 
on f.country_code = l.country_code and 
f.year = l.year
  join regions r
 on r.country_code = f.country_code);


SELECT *
FROM forestation
where country_name = 'World' and  year = 1990;

--Totla forest area in 2016

SELECT *
FROM forestation
where country_name = 'World' and  year = 2016;

--Change from 1990 to 2016

SELECT 
(SELECT forest_area_sqkm
FROM forestation
where country_name = 'World' and  year = 1990)
-
(SELECT forest_area_sqkm
FROM forestation
where country_name = 'World' and  year = 2016) as difference;

--Change in percentage

SELECT 
((SELECT forest_area_sqkm
FROM forestation
where country_name = 'World' and  year = 1990)
-
(SELECT forest_area_sqkm
FROM forestation
where country_name = 'World' and  year = 2016)) 
/
(SELECT forest_area_sqkm
FROM forestation
where country_name = 'World' and  year = 1990) * 100 as diff_per;

--Country name 
SELECT DISTINCT country_name, total_area_sqkm
FROM forestation
WHERE total_area_sqkm BETWEEN 1270000 AND  1300000;

--2. REGIONAL OUTLOOK
Question a
SELECT region, 
(SUM(forest_area_sqkm) * 100 / SUM(total_area_sqkm))
as percentage_forest_2016
FROM forestation
WHERE year = 2016
group by region
order by percentage_forest_2016 DESC;

--Country level practice

WITH forest_1990
AS
(SELECT DISTINCT country_name, forest_area_sqkm as f_1990
FROM forestation
WHERE year = 1990),

forest_2016 
AS                                  
(SELECT forest_area_sqkm as f_2016
FROM forestation
WHERE year = 2016),

diffs
AS 
(SELECT DISTINCT country_name, f_1990, f_2016,
 f_2016-f_1990 AS diff, f_2016-f_1990/f_1990*100 AS diff_perc
FROM forest_1990, forest_2016)

SELECT DISTINCT country_name, f_1990, f_2016, diff,
ROUND(diff_perc :: NUMERIC,2) AS diff_perc
FROM diffs;





--3. COUNTRY-LEVEL DETAIL
                                
WITH countries_2016 AS
(
  SELECT forest_area_sqkm AS c_2016, country_name, region
  FROM forestation
  WHERE year = 2016 and forest_area_sqkm IS NOT NULL),
 
  countries_1990 AS
 (
    SELECT forest_area_sqkm AS c_1990, country_name, region
  FROM forestation
  WHERE year = 1990 and forest_area_sqkm IS NOT NULL)
            
SELECT country_name, (c_2016 - c_1990) AS forest_change,
countries_1990.region
FROM countries_1990
JOIN countries_2016
using (country_name)
ORDER BY forest_change limit 6;

--Percentage decrease country level
WITH countries_2016 AS
(
  SELECT forest_area_sqkm AS c_2016, country_name, region
  FROM forestation
  WHERE year = 2016 and forest_area_sqkm IS NOT NULL),
 
  countries_1990 AS
 (
    SELECT forest_area_sqkm AS c_1990, country_name, region
  FROM forestation
  WHERE year = 1990 and forest_area_sqkm IS NOT NULL)
            
SELECT country_name, 
(c_2016 - c_1990)/c_1990*100 AS forest_change_percentage,
countries_1990.region,
ROUND(((c_2016 - c_1990)*100/c_1990)::NUMERIC,2)AS fc_percentage
FROM countries_1990
JOIN countries_2016
using (country_name)
ORDER BY fc_percentage limit 6;

--quartiles

WITH Q1
AS (SELECT f.country_name, f.perc,
CASE
WHEN f.perc >= 75 THEN '75%-100%'
WHEN f.perc >= 50 THEN '50%-75%'
WHEN f.perc >= 25 THEN '25%-50%'
ELSE '0-25%'
END AS quartiles
FROM forestation f 
WHERE year = 2016 and f.perc IS NOT NULL
AND country_name != 'World')
SELECT quartiles, Count (*)
FROM Q1
GROUP BY quartiles
ORDER BY quartiles;





