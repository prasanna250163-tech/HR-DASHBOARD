-- QUESTIONS
select * from hr;
-- 1. What is the gender breakdown of employees in the company?

select gender, count(*) Count from hr
where termdate is null and age >= 18
group by gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?

select race, count(*) Count from Hr
where termdate is null and age >=18
group by race;

-- 3. What is the age distribution of employees in the company?

select 
max(age) as oldest, 
min(age) as youngest
from hr
where age>=18 and termdate is null;

select 
   case
   when  age>= 18  and age<=24 then '18-24'
   when  age>= 25  and age<= 34 then '25-34'
   when  age >=35 and age <= 44 then '35-44'
   when  age >=45  and age <= 64 then '44- 54'	
   else '65+'
end age_group, gender,
count(*) as Count
from hr
where age>= 18 and termdate is null
group by age_group, gender
order by age_group, gender;

-- 4. How many employees work at headquarters versus remote locations?

select location, count(*) as Count
from hr
where age >= 18
and 
termdate is null
group by location;

-- 5. What is the average length of employment for employees who have been terminated?

select round(avg(datediff(termdate, hire_date))/365,0) as Average_length_EMP
from hr
where termdate <= curdate() and termdate is not null and age >= 18;

-- 6. How does the gender distribution vary across departments and job titles?

select gender, department, jobtitle, count(*) as count
from hr
where termdate is null and age >=18
group by gender, department, jobtitle;

-- 7. What is the distribution of job titles across the company?
select jobtitle, count(*) as count 
from hr
where termdate is null and age>= 18
group by jobtitle
order by jobtitle desc;

-- 8. Which department has the highest turnover rate?

SELECT 
    department,
    COUNT(*) AS total_count,

    SUM(CASE 
        WHEN termdate IS NOT NULL 
             AND termdate <= CURDATE()
        THEN 1 ELSE 0 
    END) AS termination_count,

    SUM(CASE 
        WHEN termdate IS NULL 
             OR termdate > CURDATE()
        THEN 1 ELSE 0 
    END) AS active_count,

    ROUND(
        SUM(CASE 
            WHEN termdate IS NOT NULL 
                 AND termdate <= CURDATE()
            THEN 1 ELSE 0 
        END) / COUNT(*) * 100,
        2
    ) AS termination_rate

FROM hr
WHERE age >= 18
GROUP BY department
ORDER BY termination_rate DESC;


-- 9. What is the distribution of employees across locations by city and state?

select count(*) as Count, location_city, location_state from hr
where termdate is null and age >=18
group by location_city, location_state;

-- 10. How has the company's employee count changed over time based on hire and term dates?

select year, hires, terminations, (hires-terminations) as net_change, 
round(((hires-terminations)/hires*100),2) as net_change_percent
from (
select year(hire_date) as year, 
count(*) as hires, 
sum(case when termdate is null and termdate <= curdate() then 1 else 0 end) as terminations
from hr
where age>=18
group by  
year(hire_date)
) sub_query
order by year asc;

-- 11. What is the tenure distribution for each department?

select department, round(avg(datediff(curdate(), termdate)/365),0) as avg_tenure
from hr
where termdate <= curdate and termdate is null and age >= 18
group by department;
