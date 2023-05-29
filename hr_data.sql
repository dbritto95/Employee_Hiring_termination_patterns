/*Creating a new database called employee*/
create database employee;

/* Importing the data file hr_data */
use employee;

SELECT hire_date,termdate
FROM employee.hr_data;

-- knowing data types 
SELECT 
  column_name, 
  data_type
FROM 
  information_schema.columns
WHERE 
  table_name = 'hr_data';

/* changing the id column name, which is not in proper order ï»¿id */
ALter table hr_data
change column ï»¿id emp_id VARCHAR(20) NULL;  /*could have used Integer but data represents some text */

SELECT *
		FROM employee.hr_data;
        
-- To know the numeric data format for the columns holding numeric data
SELECT birthdate,
       CASE 
           WHEN birthdate REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN 'YYYY-MM-DD'
           WHEN birthdate REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN 'MM/DD/YYYY'
           WHEN birthdate REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN 'MM-DD-YYYY'
           ELSE 'UNKNOWN' 
       END AS date_format
FROM hr_data;

/* Data cleaning process*/  
-- changing text types of birthdate, hire_date, termdate coloumn to date data type
SELECT gender, COUNT(*) AS count
FROM employee.hr_data
GROUP BY 1;

SELECT department, COUNT(*) AS count
FROM employee.hr_data
GROUP BY 1;

ALTER TABLE employee.hr_data ADD full_name VARCHAR(255);
UPDATE employee.hr_data
SET full_name = CONCAT(first_name, ' ', last_name);

UPDATE hr_data 
SET birthdate = CASE 
		WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%y-%m-%d')
		WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%y-%m-%d')
		ELSE NULL 
	END;
ALTER TABLE hr_data MODIFY column birthdate DATE;

UPDATE hr_data 
SET hire_date = CASE 
		WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
		WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
		ELSE NULL 
	END;
ALTER TABLE hr_data MODIFY column hire_date DATE;

UPDATE hr_data 
SET termdate = DATE(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '' AND LENGTH(termdate)>0;

-- Adding age column to the table to know the age of the employees
ALTER TABLE hr_data
ADD COLUMN age INT;
Update hr_data
SET age = timestampdiff(YEAR, birthdate, CURDATE());

-- updated termdate column blank cells with null value and text type to date format
UPDATE hr_data 
SET termdate = NULL
Where termdate IS NULL; 
ALTER TABLE hr_data MODIFY column termdate DATE;

-- Need to clean some unwanted data as we have got age value in negative in age column
UPDATE hr_data -- using date_sub and ABS function converted negative value to positive value in age column and subtracting the age from year 
SET birthdate = DATE_SUB(birthdate, INTERVAL YEAR(birthdate) - YEAR(CURDATE()) - age YEAR),
    age = ABS(age)
WHERE age < 0;

-- there are 1527 termdate rows of records which are not recorded properly.
--  '2029-10-29' for instance termination date is in the future which also contradiacts with other column like birthdate, hire_date 
DELETE FROM employee.hr_data
WHERE termdate > '2023-09-28';

SELECT *
FROM employee.hr_data;

-- Data analysing 

-- employees with the age group
SELECT location_state,gender,
  CASE
    WHEN age >= 20 AND age <= 30 THEN '20-30'
    WHEN age >= 31 AND age <= 40 THEN '31-40'
    WHEN age >= 41 AND age <= 50 THEN '41-50'
    WHEN age >= 51 AND age <= 60 THEN '51-60'
    ELSE '65+'
  END AS age_group,
  COUNT(*) AS employee_count
FROM employee.hr_data
GROUP BY age_group,gender, location_state;

-- 1. What is the distribution of gender and race among employees?
SELECT gender, race, COUNT(*) AS gender_race_distribution
FROM employee.hr_data
GROUP BY gender,race;

-- 2.How many employees have been hired and terminated in each department?
SELECT department,
       COUNT(CASE WHEN termdate IS NULL THEN 1 END) AS hired_count,
       COUNT(CASE WHEN termdate IS NOT NULL THEN 1 END) AS terminated_count
FROM employee.hr_data
GROUP BY department;

-- 3.What is the average tenure of employees in each department?
SELECT department,COUNT(*),
    AVG(DATEDIFF(termdate, hire_date)/365) AS average_tenure_years  
FROM employee.hr_data
GROUP BY department;


-- 4.What is the most common jobtitle in each department? 
SELECT department, jobtitle, COUNT(*) AS common_jobtitle
FROM employee.hr_data
GROUP BY department, jobtitle 	-- checked for the counts by department and jobtitle 
HAVING common_jobtitle = (		-- Selecting maximum counts from common_jobtitle counts by using having function
    SELECT MAX(subcount)		-- using max function  to find maxiumum count in the department and jobtitle
    FROM (
        SELECT department, jobtitle, COUNT(*) AS subcount 
        FROM employee.hr_data
        GROUP BY department, jobtitle
    ) AS subquery									-- used subquery to get the maximum counts from common_jobtitle as subcount
    WHERE subquery.department = hr_data.department); -- equalising both the queries 

-- Maximum working tenure    
SELECT full_name, location_state,location_city, hire_date, datediff('2020-12-13' ,hire_date)/365 AS tenure
FROM employee.hr_data
WHERE hire_date <= '2020-12-13'
ORDER BY tenure DESC;

    
-- 5.How does the location affect employee retention?
SELECT location, 
       COUNT(*) AS total_employees,
       COUNT(CASE WHEN termdate IS NULL THEN 1 END) AS retained_employees,
       COUNT(CASE WHEN termdate IS NOT NULL THEN 1 END) AS terminated_employees,
       COUNT(CASE WHEN termdate IS NULL THEN 1 END) / COUNT(*) * 100 AS retention_rate
FROM employee.hr_data
GROUP BY location;    


-- 6.Are there any significant differences in the employment patterns based on gender and race?	
SELECT race,gender,year(hire_date) as year, COUNT(*), 
       SUM(CASE WHEN termdate IS NULL THEN 1 ELSE 0 END) AS hired_count,
       SUM(CASE WHEN termdate IS NOT NULL THEN 1 ELSE 0 END) AS terminated_count
FROM employee.hr_data
GROUP BY race,gender,year
ORDER BY year;


-- 7. Average employement tenure of terminated employees
SELECT
       AVG(DATEDIFF(termdate, hire_date) / 365) AS avg_employment_length,
       COUNT(*) AS employee_count
FROM hr_data; 

-- 8. Average employement tenure as per gender and race of all employees
SELECT gender,race,
       AVG(DATEDIFF(termdate, hire_date) / 365) AS avg_employment_length,
       COUNT(*) AS employee_count
FROM hr_data
GROUP BY gender,race;

SELECT gender, race, full_name,
       MAX(DATEDIFF(curdate(), hire_date) / 365) AS max_employment_length
FROM hr_data
WHERE termdate IS NOT NULL
GROUP BY gender, race, full_name;


-- 9.Termination rate of employees as per department?
SELECT department, total_count, terminated_count, terminated_count/total_count*100 As termination_rate
FROM (SELECT department, COUNT(*) AS total_count,
	SUM(case when termdate <=curdate() then 1 else 0 END) AS terminated_count
	FROM employee.hr_data
GROUP BY department)as subquery;

-- 10. Count of employees by gender 
SELECT gender, COUNT(*) 
FROM employee.hr_data
GROUP BY gender;
 
-- 11. employee details
SELECT full_name, gender, department, age, location_state
FROM employee.hr_data;

-- 12.how has the companys employee count changed over time based on hire and term dates? 
SELECT Year, hires, terminations, hires-terminations AS net_change, ROUND(((hires-terminations)/hires*100), 2) AS net_change_percentage 
FROM (
    SELECT YEAR(hire_date) AS Year, -- used a subquery to get the employee count changed table by using hire_date column and termdate column 
           COUNT(*) AS hires,
           SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
    FROM employee.hr_data
    GROUP BY Year
) AS subquery;

Select COUNT(distinct jobtitle) AS unique_jobtitle,
		COUNT(distinct department) AS unique_department
FROM employee.hr_data;

SELECT location_state, COUNT(*) As employee_count,
MIN(age) as average_age
FROM employee.hr_data
GROUP BY location_state;



SELECT gender, YEAR(hire_date) AS year,  COUNT(*) AS hires
FROM employee.hr_data
GROUP BY year,gender
ORDER BY year;	

SELECT full_name, location_state, hire_date, COUNT(*)
FROM employee.hr_data
GROUP BY 1,2,3;