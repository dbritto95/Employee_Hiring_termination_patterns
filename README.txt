Employee Data Analysis By Using SQL and Power BI

* Problem Statement:-
	To understand the trends of employment patterns in a company.

* Key variable :- There are 13 columns and 22214 rows of data from which below main key variables are used to analyse the data 
	*Gender
	*Race
	*Department
	*Jobtitle
	*Hire date
	*Term date
	*Age
*****

Data cleaning and Normalization process:-

*Total number of rows in the dataset is 22214;
*We get total 3929 count of rows for the termdate column due to null values which will not affect the data analysing part.
*There are no duplicates

** The id column was not properly named (ï»¿id) which was later changed to emp_id
** Data types are in text format which need to be changed to releveant data type
	**birthdate column, hire_date, termdate 
*I have some of data with unkown format and some of the  'MM/DD/YYYY' format in birthdate column
	** Further changed the format to %Y-%m-%d format
*Changed the data type of all the required columns to date format which were in text format

Added age column with below query to know the age of the employees
Update hr_data
SET age = timestampdiff(YEAR, birthdate, CURDATE()); -- it calculates age of an individual by taking difference between currentdate and birthdate.

After updating the age column i found some negative records in age column which indicates wrong data was recorded in the birthdate column 
2069-12-28 -46 this is the output
Here i can use this query to make the changes in the data

SELECT emp_id, birthdate, age,
       DATE_SUB(birthdate, INTERVAL ABS(age) YEAR) AS corrected_birthdate, -- Date_SUB function used to subtract the date by using age difference
       ABS(age) AS corrected_age -- ABS function used to convert negative to positive value
FROM hr_data
WHERE age < 0;

**further to reduce the age by 46 years below query was performed 

UPDATE hr_data
SET birthdate = DATE_SUB(birthdate, INTERVAL age YEAR),
    age = ABS(age)
WHERE age < 0;

**Output 2023-12-28 46 ** here we came to know the birthdate year was recorded twice the addition of age so further used below query to get the normal output

UPDATE hr_data
SET birthdate = DATE_SUB(birthdate, INTERVAL YEAR(birthdate) - YEAR(CURDATE()) - age YEAR)-- here using the DATE_SUB function subtracting current date year and subtracting age year got below output
WHERE age < 0;

**Output 1977-12-28 **

-- there are 1527 termdate rows of records which are not recorded properly.
--  '2029-10-29' for instance termination date is in the future which also contradiacts with other column like birthdate, hire_date 
DELETE FROM employee.hr_data
WHERE termdate > '2023-09-28'; 

***** Data analysing questions
1.What is the distribution of gender and race among employees?
2.How many employees have been hired and terminated in each department?
3.What is the average tenure of employees in each department?
4.What is the most common jobtitle in each department?
5.How does the location affect employee retention?
6.Are there any significant differences in the employment patterns based on gender and race?

Great! Here are some steps you can follow to formulate your problem statement and questions to analyze the employee data in SQL:

Define your problem statement: Your problem statement should clearly explain the purpose of your analysis. For example, "To understand the employee demographics and employment patterns in a company."

Identify your key variables: Based on the columns in your data set, identify the variables that you want to analyze. For example, "Gender, Race, Department, Jobtitle, Hire date, and Term date."

Formulate your research questions: Your research questions should be specific, measurable, and relevant to your problem statement. Here are some examples:

What is the distribution of gender and race among employees?
How many employees have been hired and terminated in each department?
What is the average tenure of employees in each department?
What is the most common jobtitle in each department?
How does the location affect employee retention?
Are there any significant differences in the employment patterns based on gender and race?
Plan your analysis: Based on your research questions, plan your analysis. For example, you can use SQL queries to calculate summary statistics, visualize data using charts and graphs, and perform hypothesis testing to identify any significant differences in employment patterns based on gender and race.

Document your findings: Once you have completed your analysis, document your findings in a clear and concise manner. You can create charts, graphs, and tables to support your conclusions.

Draw insights and recommendations: Based on your findings, draw insights and recommendations that can help the company to improve its employee retention, diversity, and inclusion practices.

I hope this helps!
