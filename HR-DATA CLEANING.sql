USE projects;

-- View HR data
SELECT * FROM hr;


-- Rename employee ID column
ALTER TABLE hr
CHANGE COLUMN `ï»¿id` emp_id VARCHAR(20) NULL;


-- Check structure
DESCRIBE hr;


-- =========================
-- DATA CLEANING
-- =========================

SET SQL_SAFE_UPDATES = 0;


-- Clean Birthdate
UPDATE hr
SET birthdate = CASE
    WHEN birthdate LIKE '%/%'
        THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%'
        THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;


ALTER TABLE hr
MODIFY COLUMN birthdate DATE;


-- Clean Hire Date
UPDATE hr
SET hire_date = CASE
    WHEN hire_date LIKE '%/%'
        THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%'
        THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;


ALTER TABLE hr
MODIFY COLUMN hire_date DATE;


-- Clean Termination Date
UPDATE hr
SET termdate = DATE(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL
  AND termdate != '';


UPDATE hr
SET termdate = NULL
WHERE TRIM(termdate) = '';


ALTER TABLE hr
MODIFY COLUMN termdate DATE;


-- =========================
-- CREATE AGE COLUMN
-- =========================

ALTER TABLE hr
ADD COLUMN Age INT;


UPDATE hr
SET Age = TIMESTAMPDIFF(YEAR, birthdate, CURDATE());


-- =========================
-- DATA CHECKS
-- =========================

SELECT
    MIN(Age) AS youngest,
    MAX(Age) AS oldest
FROM hr;


SELECT COUNT(*)
FROM hr
WHERE Age < 18;


SELECT COUNT(*)
FROM hr
WHERE termdate > CURDATE();


SELECT COUNT(*)
FROM hr
WHERE termdate IS NULL;


-- =========================
-- HR DASHBOARD ANALYSIS
-- =========================


-- 1. Gender distribution
SELECT
    gender,
    COUNT(*) AS Count
FROM hr
WHERE termdate IS NULL
  AND Age >= 18
GROUP BY gender;


-- 2. Race distribution
SELECT
    race,
    COUNT(*) AS Count
FROM hr
WHERE termdate IS NULL
  AND Age >= 18
GROUP BY race;


-- 3. Youngest and oldest employees
SELECT
    MAX(Age) AS oldest,
    MIN(Age) AS youngest
FROM hr
WHERE Age >= 18
  AND termdate IS NULL;


-- 4. Age group distribution
SELECT
    CASE
        WHEN Age >= 18 AND Age <= 24 THEN '18-24'
        WHEN Age >= 25 AND Age <= 34 THEN '25-34'
        WHEN Age >= 35 AND Age <= 44 THEN '35-44'
        WHEN Age >= 45 AND Age <= 64 THEN '44- 54'
        ELSE '65+'
    END AS age_group,
    COUNT(*) AS Count
FROM hr
WHERE Age >= 18
  AND termdate IS NULL
GROUP BY age_group
ORDER BY age_group;


-- 5. Age group by gender
SELECT
    CASE
        WHEN Age >= 18 AND Age <= 24 THEN '18-24'
        WHEN Age >= 25 AND Age <= 34 THEN '25-34'
        WHEN Age >= 35 AND Age <= 44 THEN '35-44'
        WHEN Age >= 45 AND Age <= 64 THEN '44- 54'
        ELSE '65+'
    END AS age_group,
    gender,
    COUNT(*) AS Count
FROM hr
WHERE Age >= 18
  AND termdate IS NULL
GROUP BY age_group, gender
ORDER BY age_group, gender;


-- 6. Employees by work location
SELECT
    location,
    COUNT(*) AS Count
FROM hr
WHERE Age >= 18
  AND termdate IS NULL
GROUP BY location;


-- 7. Average employment length of terminated employees
SELECT
    ROUND(AVG(DATEDIFF(termdate, hire_date)) / 365, 0)
        AS Average_length_EMP
FROM hr
WHERE termdate <= CURDATE()
  AND termdate IS NOT NULL
  AND Age >= 18;


-- 8. Gender, Department and Job Title distribution
SELECT
    gender,
    department,
    jobtitle,
    COUNT(*) AS Count
FROM hr
WHERE termdate IS NULL
  AND Age >= 18
GROUP BY gender, department, jobtitle;


-- 9. Job title distribution
SELECT
    jobtitle,
    COUNT(*) AS Count
FROM hr
WHERE termdate IS NULL
  AND Age >= 18
GROUP BY jobtitle
ORDER BY jobtitle DESC;


-- 10. Termination rate by Department
SELECT
    department,
    COUNT(*) AS total_count,

    SUM(
        CASE
            WHEN termdate IS NOT NULL
                 AND termdate <= CURDATE()
            THEN 1
            ELSE 0
        END
    ) AS termination_count,

    SUM(
        CASE
            WHEN termdate IS NULL
                 OR termdate > CURDATE()
            THEN 1
            ELSE 0
        END
    ) AS active_count,

    ROUND(
        SUM(
            CASE
                WHEN termdate IS NOT NULL
                     AND termdate <= CURDATE()
                THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS termination_rate

FROM hr
WHERE Age >= 18
GROUP BY department
ORDER BY termination_rate DESC;


-- 11. Employees by City and State
SELECT
    COUNT(*) AS Count,
    location_city,
    location_state
FROM hr
WHERE termdate IS NULL
  AND Age >= 18
GROUP BY location_city, location_state;


-- 12. Employee change by year
SELECT
    year,
    hires,
    terminations,
    (hires - terminations) AS net_change,
    ROUND(
        ((hires - terminations) / hires * 100),
        2
    ) AS net_change_percent
FROM (
    SELECT
        YEAR(hire_date) AS year,
        COUNT(*) AS hires,
        SUM(
            CASE
                WHEN termdate IS NULL
                     AND termdate <= CURDATE()
                THEN 1
                ELSE 0
            END
        ) AS terminations
    FROM hr
    WHERE Age >= 18
    GROUP BY YEAR(hire_date)
) sub_query
ORDER BY year ASC;


-- 13. Average tenure by Department
SELECT
    department,
    ROUND(
        AVG(
            DATEDIFF(
                CASE
                    WHEN termdate IS NULL THEN CURDATE()
                    ELSE termdate
                END,
                hire_date
            ) / 365
        ),
        0
    ) AS avg_tenure
FROM hr
WHERE Age >= 18
GROUP BY department;