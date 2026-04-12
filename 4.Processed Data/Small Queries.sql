SELECT 
  A.UserID0,
  B.Name,
  B.Gender,
  B.Age,
  B.Province,
  A.Channel2,
  A.RecordDate2,
  A.`Duration 2`
FROM workspace.default.bright_tv_v A
LEFT JOIN workspace.default.bright_tv_u B
ON A.UserID0 = B.UserID;


--count total views  
SELECT COUNT(*) AS TotalViews
FROM workspace.default.bright_tv_v;



--2. TOP CHANNEL VIEWED 

SELECT 
  Channel2,
  COUNT(*) AS TotalViews
FROM workspace.default.bright_tv_v A
GROUP BY Channel2
ORDER BY TotalViews DESC;





--3. UNIQUE USERS PER CHANNEL

SELECT 
  Channel2,
  COUNT(DISTINCT UserID0) AS UniqueUsers
FROM workspace.default.bright_tv_v A
GROUP BY Channel2
ORDER BY UniqueUsers 
DESC;





--4. VIEWING BY PROVINCE

SELECT 
  B.Province,
  COUNT(*) AS TotalViews
FROM workspace.default.bright_tv_v A
JOIN workspace.default.bright_tv_u B
ON A.UserID0 = B.UserID
GROUP BY B.Province
ORDER BY TotalViews 
DESC;




--5. VIEWING BY GENDER
SELECT 
  B.Gender,
  COUNT(*) AS TotalViews
FROM workspace.default.bright_tv_v A
JOIN workspace.default.bright_tv_u B
ON A.UserID0 = B.UserID
GROUP BY B.Gender
ORDER BY TotalViews DESC;




----6. VIEWING BY AGE GROUP
SELECT
  CASE  
    WHEN B.Age <= 9 THEN 'Kids'
    WHEN B.Age BETWEEN 10 AND 16 THEN 'Teens'
    WHEN B.Age BETWEEN 17 AND 24 THEN 'Youth'
    WHEN B.Age BETWEEN 25 AND 35 THEN 'Adults'
    WHEN B.Age BETWEEN 36 AND 55 THEN 'Older Adults'
    WHEN B.Age BETWEEN 56 AND 75 THEN 'Seniors'
    WHEN B.Age BETWEEN 76 AND 99 THEN 'Elderly'
    ELSE 'Unknown'
  END AS Age_Group,
  CASE  
    WHEN B.Age <= 9 THEN '0-9'
    WHEN B.Age BETWEEN 10 AND 16 THEN '10-16'
    WHEN B.Age BETWEEN 17 AND 24 THEN '17-24'
    WHEN B.Age BETWEEN 25 AND 35 THEN '25-35'
    WHEN B.Age BETWEEN 36 AND 55 THEN '36-55'
    WHEN B.Age BETWEEN 56 AND 75 THEN '56-75'
    WHEN B.Age BETWEEN 76 AND 99 THEN '76-99'
    ELSE 'N/A'
  END AS Age_Bracket,
  COUNT(*) AS Count
FROM workspace.default.bright_tv_v A
JOIN workspace.default.bright_tv_u B
ON A.UserID0 = B.UserID
GROUP BY
  Age_Group,
  Age_Bracket
ORDER BY
  Count DESC;



  --TOP USERS (ENGAGEMENT)
  
SELECT 
  A.UserID0 AS UserID,
  B.Name,
  COUNT(*) AS TotalViews
FROM workspace.default.bright_tv_v A
LEFT JOIN workspace.default.bright_tv_u B
  ON A.UserID0 = B.UserID
GROUP BY A.UserID0, B.Name
ORDER BY TotalViews DESC
LIMIT 100;




--convert time stemp TO SA time

SELECT 
  A.RecordDate2,
  DATE_FORMAT(CONVERT_TIMEZONE('UTC', 'Africa/Johannesburg', A.RecordDate2), 'yyyy-MM-dd') AS formatted_date_sa,
  DATE_FORMAT(CONVERT_TIMEZONE('UTC', 'Africa/Johannesburg', A.RecordDate2), 'HH:mm:ss') AS formatted_time_sa
FROM workspace.default.bright_tv_v A
LEFT JOIN workspace.default.bright_tv_u B
ON A.UserID0 = B.UserID
LIMIT 100;




--VIEWING PATTERNS BY GENDER 

SELECT 
  B.Gender,
  DATE_FORMAT(CONVERT_TIMEZONE('UTC', 'Africa/Johannesburg', A.RecordDate2), 'yyyy-MM-dd') AS ViewDate_SA,
  COUNT(*) AS TotalViews,
  SUM(
    HOUR(A.`Duration 2`) * 3600 + 
    MINUTE(A.`Duration 2`) * 60 + 
    SECOND(A.`Duration 2`)
  ) AS TotalDurationSeconds
FROM workspace.default.bright_tv_v A
JOIN workspace.default.bright_tv_u B
ON A.UserID0 = B.UserID
GROUP BY B.Gender, ViewDate_SA
ORDER BY B.Gender, ViewDate_SA;

---Time viewers spend on a channel
SELECT 
  Channel2,
  COUNT(*) AS TotalViews,
  CONCAT(
    LPAD(CAST(FLOOR(SUM(HOUR(`Duration 2`) * 3600 + MINUTE(`Duration 2`) * 60 + SECOND(`Duration 2`)) / 3600) AS STRING), 3, '0'), ':',
    LPAD(CAST(FLOOR((SUM(HOUR(`Duration 2`) * 3600 + MINUTE(`Duration 2`) * 60 + SECOND(`Duration 2`)) % 3600) / 60) AS STRING), 2, '0'), ':',
    LPAD(CAST(FLOOR(SUM(HOUR(`Duration 2`) * 3600 + MINUTE(`Duration 2`) * 60 + SECOND(`Duration 2`)) % 60) AS STRING), 2, '0')
  ) AS TotalDuration_HHHMMSS
FROM workspace.default.bright_tv_v A
GROUP BY Channel2
ORDER BY TotalViews DESC;




-- AGGREGATION: Viewing Patterns by Province

SELECT 
  B.Province,
  DATE_FORMAT(CONVERT_TIMEZONE('UTC', 'Africa/Johannesburg', A.RecordDate2), 'yyyy-MM-dd') AS ViewDate_SA,
  COUNT(*) AS TotalViews,
  SUM(
    HOUR(A.`Duration 2`) * 3600 + 
    MINUTE(A.`Duration 2`) * 60 + 
    SECOND(A.`Duration 2`)
  ) AS TotalDurationSeconds
FROM workspace.default.bright_tv_v A
JOIN workspace.default.bright_tv_u B
ON A.UserID0 = B.UserID
GROUP BY B.Province, ViewDate_SA
ORDER BY B.Province;


--AGGREGATION: Daily Viewing Trends

SELECT 
  DATE(Viewing_Date_SA) AS viewing_date_sa,
  DAYOFWEEK(Viewing_Date_SA) AS day_of_week,
  CASE DAYOFWEEK(Viewing_Date_SA)
    WHEN 1 THEN 'Sunday'
    WHEN 2 THEN 'Monday'
    WHEN 3 THEN 'Tuesday'
    WHEN 4 THEN 'Wednesday'
    WHEN 5 THEN 'Thursday'
    WHEN 6 THEN 'Friday'
    WHEN 7 THEN 'Saturday'
  END AS day_name,
  COUNT(*) AS total_views,
  COUNT(DISTINCT UserID) AS unique_viewers,
  SUM(DurationSeconds) AS total_seconds,
  CONCAT(
    LPAD(CAST(FLOOR(SUM(DurationSeconds) / 3600) AS STRING), 2, '0'), ':',
    LPAD(CAST(FLOOR((SUM(DurationSeconds) % 3600) / 60) AS STRING), 2, '0'), ':',
    LPAD(CAST(FLOOR(SUM(DurationSeconds) % 60) AS STRING), 2, '0')
  ) AS total_duration_formatted
FROM workspace.default.bright_tv_combined
WHERE Viewing_Date_SA IS NOT NULL
GROUP BY DATE(Viewing_Date_SA), DAYOFWEEK(Viewing_Date_SA)
ORDER BY viewing_date_sa;



--MOST WATCHED CHANNELS
SELECT 
  Channel2,
  COUNT(*) AS TotalViews,
  COUNT(DISTINCT UserID0) AS UniqueViewers,
  SUM(
    HOUR(`Duration 2`) * 3600 + 
    MINUTE(`Duration 2`) * 60 + 
    SECOND(`Duration 2`)
  ) AS TotalDurationSeconds,
  CONCAT(
    LPAD(CAST(FLOOR(SUM(HOUR(`Duration 2`) * 3600 + MINUTE(`Duration 2`) * 60 + SECOND(`Duration 2`)) / 3600) AS STRING), 2, '0'), ':',
    LPAD(CAST(FLOOR((SUM(HOUR(`Duration 2`) * 3600 + MINUTE(`Duration 2`) * 60 + SECOND(`Duration 2`)) % 3600) / 60) AS STRING), 2, '0'), ':',
    LPAD(CAST(FLOOR(SUM(HOUR(`Duration 2`) * 3600 + MINUTE(`Duration 2`) * 60 + SECOND(`Duration 2`)) % 60) AS STRING), 2, '0')
  ) AS TotalDurationFormatted
FROM workspace.default.bright_tv_v
GROUP BY Channel2
ORDER BY TotalViews DESC
LIMIT 10;



-- AGGREGATION: Viewing by Time of Day

SELECT
  DATE_FORMAT(CONVERT_TIMEZONE('UTC', 'Africa/Johannesburg', A.RecordDate2), 'HH') AS hour_sa,
  COUNT(*) AS total_views,
  SUM(
    HOUR(A.`Duration 2`) * 3600 +
    MINUTE(A.`Duration 2`) * 60 +
    SECOND(A.`Duration 2`)
  ) AS total_duration_seconds
FROM workspace.default.bright_tv_v A
GROUP BY hour_sa
ORDER BY hour_sa;
