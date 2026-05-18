
use New_Project;
go 

--check common column key
select top 5 * from dailyActivity_merged;
select top 5  * from sleepDay_merged;

--convert Date formatsALTER TABLE daily_activityal
alter table dailyActivity_merged
ALTER COLUMN ActivityDate DATE; 

ALTER TABLE sleepDay_merged
ALTER COLUMN SleepDay DATE;

--Main join tables

--1. Daily Activity + Sleep Data

SELECT
    d.Id,
    d.ActivityDate,
    d.TotalSteps,
    d.Calories,
    s.TotalMinutesAsleep
FROM dailyActivity_merged d
LEFT JOIN sleepDay_merged s
ON d.Id = s.Id
AND d.ActivityDate = s.SleepDay;

--2. Activity + Weight

SELECT
    d.Id,
    d.ActivityDate,
    d.TotalSteps,
    w.WeightKg
FROM dailyActivity_merged d
LEFT JOIN weightLogInfo_merged w
ON d.Id = w.Id
AND d.ActivityDate = w.Date;

--3. Hourly Steps + Hourly Calories

SELECT
    hs.Id,
    hs.ActivityHour,
    hs.StepTotal,
    hc.Calories
FROM hourlySteps_merged hs
INNER JOIN hourlyCalories_merged hc
ON hs.Id = hc.Id
AND hs.ActivityHour = hc.ActivityHour;


--Null values update 
update sleepDay_merged
set TotalMinutesAsleep=0 
where TotalMinutesAsleep is null;


--remove duplicates 
WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY Id, ActivityDate
               ORDER BY Id
           ) rn
    FROM dailyActivity_merged
)
DELETE FROM cte
WHERE rn > 1;


--A) User Activity Insights
--1. Most Active Users
SELECT TOP 10
    Id,
    AVG(TotalSteps) avg_steps
FROM dailyActivity_merged
GROUP BY Id
ORDER BY avg_steps DESC;

--Insight:Find higly active users 

--2. Least Active Users
SELECT TOP 10
    Id,
    AVG(TotalSteps) avg_steps
FROM dailyActivity_merged
GROUP BY Id
ORDER BY avg_steps ASC;

--Insight:Target Inactive users for marketing

--B) Sleep Analysis
--Average Sleep Hours
SELECT
    Id,
    AVG(TotalMinutesAsleep)/60.0 avg_sleep_hours
FROM sleepDay_merged
GROUP BY Id;

--Insight: Check whether users get proper sleep.

--C) Calories vs Steps
SELECT
    TotalSteps,
    Calories
FROM dailyActivity_merged;

--Insight:  Higher steps = higher calorie burn.  Very important business insight.

--D) Weekend vs Weekday Activity
SELECT
    DATENAME(WEEKDAY, ActivityDate) day_name,
    AVG(TotalSteps) avg_steps
FROM dailyActivity_merged
GROUP BY DATENAME(WEEKDAY, ActivityDate);

--Insight: Users may exercise more on weekends.

--E) Hourly Activity Pattern

SELECT
    DATEPART(HOUR, ActivityHour) hour_of_day,
    AVG(StepTotal) avg_steps
FROM hourlySteps_merged
GROUP BY DATEPART(HOUR, ActivityHour)
ORDER BY hour_of_day;

--Insight: Find peak workout hours.

--F) Sleep vs Activity Correlation

SELECT
    d.Id,
    AVG(d.TotalSteps) avg_steps,
    AVG(s.TotalMinutesAsleep)/60 avg_sleep
FROM dailyActivity_merged d
JOIN sleepDay_merged s
ON d.Id = s.Id
AND d.ActivityDate = s.SleepDay
GROUP BY d.Id;

--Insight: Do active users sleep better

--G) Weight vs Calories Burned

SELECT
    w.WeightKg,
    AVG(d.Calories) avg_calories
FROM weightLogInfo_merged w
JOIN dailyActivity_merged d
ON w.Id = d.Id
GROUP BY w.WeightKg;

--Insight:  Relationship between weight and calorie burn.

--H) Sedentary Lifestyle Detection

SELECT
    Id,
    AVG(SedentaryMinutes) avg_sedentary
FROM dailyActivity_merged
GROUP BY Id
ORDER BY avg_sedentary DESC;

--insight: Find users sitting too much.


--Step 8 — Business Recommendations

--1]Inactive users need motivational notifications
--2]Users sleep less on weekdays
--3]Peak activity time is evening
--4]Higher activity improves sleep quality
--5]Sedentary users should receive health reminders


