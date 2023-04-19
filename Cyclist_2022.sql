USE Cyclist_2022;

--Creating a new table for the whole year data
CREATE TABLE Cyclist_year_2022(
ride_id nvarchar(50),
rideable_type varchar(50),
started_at DATETIME,
ended_at DATETIME ,
start_station_name varchar(Max),
start_station_id varchar(50),
end_station_name varchar(Max),
end_station_id varchar(50),
start_lat float,
start_lng float,
end_lat float,
end_lng float,
member_casual varchar(50)
)

-- Union all 12 months tables into Cyclist_year_2022.
INSERT INTO Cyclist_year_2022
SELECT *
FROM Jan2022

UNION ALL

SELECT *
FROM Feb2022

UNION ALL

SELECT *
FROM Mar2022

UNION ALL

SELECT *
FROM Apr2022

UNION ALL

SELECT * 
FROM May2022

UNION ALL

SELECT*
FROM Jun2022

UNION ALL

SELECT *
FROM July2022

UNION ALL

SELECT *
FROM Aug2022

UNION ALL

SELECT *
FROM Sept2022

UNION ALL

SELECT *
FROM Oct2022

UNION ALL

SELECT *
FROM Nov2022

UNION ALL

SELECT *
FROM Dec2022

--checking for duplicates
SELECT ride_id,started_at, ended_at, COUNT(*) AS duplicate_count
FROM dbo.Cyclist_year_2022
GROUP BY ride_id,started_at, ended_at
HAVING COUNT(*) > 1

--Calculating Trip duration in minutes
SELECT started_at, ended_at, DATEDIFF(minute, started_at, ended_at) AS Trip_duration 
FROM dbo.Cyclist_year_2022

--creating Trip_duration column
ALTER TABLE Cyclist_year_2022
ADD Trip_duration int

UPDATE Cyclist_year_2022
SET Trip_duration = DATEDIFF(minute, started_at, ended_at)



---Rplacing NUll values in start/end Station name and start/end station Id
UPDATE Cyclist_year_2022
SET Start_station_id =
CASE 
WHEN start_station_id IS NULL THEN 'Other'
ELSE start_station_id
END
--
UPDATE Cyclist_year_2022
SET Start_station_name =
CASE 
WHEN start_station_name IS NULL THEN 'Other'
ELSE start_station_name
END
--
UPDATE Cyclist_year_2022
SET end_station_id =
CASE 
WHEN end_station_id IS NULL THEN 'Other'
ELSE end_station_id
END
--
UPDATE Cyclist_year_2022
SET end_station_name =
CASE 
WHEN end_station_name IS NULL THEN 'Other'
ELSE end_station_name
END


---Creating route_name column
ALTER TABLE Cyclist_year_2022
ADD Route_name VARCHAR(MAX)

UPDATE Cyclist_year_2022
SET Route_name =
CONCAT_WS(' to ', start_station_name, end_station_name)

---Creating route_id column
ALTER TABLE Cyclist_year_2022
ADD Route_Id VARCHAR(100)

UPDATE Cyclist_year_2022
SET Route_Id =
CONCAT_WS(' to ', start_station_Id, end_station_Id)

---converting start time to weekday
SELECT started_at, DATENAME(WEEKDAY,started_at) AS Started_Weekday
FROM Cyclist_year_2022
ORDER BY started_at, DATEPART(WEEKDAY,started_at)

----creating Started_Weekday column
ALTER TABLE Cyclist_year_2022
ADD Started_Weekday varchar(10)

UPDATE Cyclist_year_2022
SET Started_Weekday =
CASE DATEPART(WEEKDAY,started_at)
WHEN 1 THEN 'Sunday'
WHEN 2 THEN 'Monday'
WHEN 3 THEN 'Tuesday'
WHEN 4 THEN 'Wednesday'
WHEN 5 THEN 'Thursday'
WHEN 6 THEN 'Friday'
WHEN 7 THEN 'Saturday'
END


---converting End time to weekday
SELECT ended_at, DATENAME(WEEKDAY,ended_at) AS Ended_Weekday
FROM Cyclist_year_2022
ORDER BY Ended_at, DATEPART(WEEKDAY,Ended_at)

----creating Ended_Weekday column
ALTER TABLE Cyclist_year_2022
ADD Ended_Weekday varchar(10)

UPDATE Cyclist_year_2022
SET Ended_Weekday =

CASE DATEPART(WEEKDAY,Ended_at)
WHEN 1 THEN 'Sunday'
WHEN 2 THEN 'Monday'
WHEN 3 THEN 'Tuesday'
WHEN 4 THEN 'Wednesday'
WHEN 5 THEN 'Thursday'
WHEN 6 THEN 'Friday'
WHEN 7 THEN 'Saturday'
END

-----coverting datetime column to date 
SELECT CONVERT(date,started_at) AS Date
FROM Cyclist_year_2022

-----Creating date column
ALTER TABLE Cyclist_year_2022
ADD Date date

UPDATE Cyclist_year_2022
SET Date = CONVERT(date,started_at)


-------------------------------------ANALYSIS----------------------------------
---Busiest day of the week
  SELECT Weekday, COUNT(*) AS Weekday_count
FROM(
SELECT  started_weekday AS Weekday
FROM Cyclist_year_2022
UNION ALL
SELECT ended_weekday AS Weekday
FROM Cyclist_year_2022
)subquery_alias
GROUP BY Weekday
ORDER BY Weekday DESC


--Top 10 most used route by casual usertype
SELECT member_casual, Route_id, Route_name, start_lng, start_lat,end_lng, end_lat, COUNT(*) AS Trip_count
FROM Cyclist_year_2022
WHERE member_casual = 'casual'
GROUP BY member_casual, Route_id, Route_name, start_lng,start_lat,end_lng, end_lat
ORDER BY Trip_count DESC
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY

 --Top 10 most used route by  member usertype
SELECT member_casual, Route_id, Route_name, start_lng, start_lat,end_lng, end_lat, COUNT(*) AS Trip_count
FROM Cyclist_year_2022
WHERE member_casual = 'member'
GROUP BY member_casual, Route_id, Route_name, start_lng,start_lat,end_lng, end_lat
ORDER BY Trip_count DESC
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY


--Total number of trips by date
SELECT Date,member_casual, COUNT(ride_id) AS Total_Trips
FROM Cyclist_year_2022
GROUP BY Date, member_casual
ORDER BY Date

--Total number of trips by member
SELECT Date, member_casual, COUNT(member_casual) AS Total_member_Trips
FROM Cyclist_year_2022
WHERE member_casual = 'member'
GROUP BY Date, member_casual
ORDER BY date

--Total number of trips by casual
SELECT Date, member_casual, COUNT(member_casual) AS Total_member_Trips
FROM Cyclist_year_2022
WHERE member_casual = 'casual'
GROUP BY Date, member_casual
ORDER BY date


--Total number of trips by weekday
SELECT started_Weekday, member_casual, COUNT(ride_id) AS Total_Trips
FROM Cyclist_year_2022
GROUP BY started_Weekday, member_casual
ORDER BY started_Weekday

---Total Route
SELECT COUNT(DISTINCT Route_name) AS Route_count
FROM Cyclist_year_2022


---Total Stations
 SELECT COUNT (DISTINCT Station_id) AS Station_count
FROM(
SELECT  start_station_id AS Station_id, start_station_name AS Station_name
FROM Cyclist_year_2022
UNION
SELECT end_station_id AS Station_id, end_station_name AS Station_name
FROM Cyclist_year_2022
)subquery_alias


---tripduration by usertype per date
SELECT date, member_casual, SUM(Trip_duration)AS trip_length
FROM Cyclist_year_2022
GROUP BY date, member_casual
ORDER BY date, trip_length


---tripduration by usertype weekday
SELECT Started_weekday, member_casual, SUM(Trip_duration)AS trip_length
FROM Cyclist_year_2022
GROUP BY Started_weekday, member_casual
ORDER BY Started_weekday, trip_length

--Bike count by rideable_type
SELECT rideable_type, COUNT(rideable_type) AS Bike_count
FROM Cyclist_year_2022
GROUP BY rideable_type
ORDER BY Bike_count DESC

--Nmber of electric bike used by usertype
SELECT member_casual, COUNT(rideable_type) AS Bike_count
FROM Cyclist_year_2022
WHERE rideable_type= 'electric_bike'
GROUP BY member_casual
ORDER BY Bike_count DESC

--Nmber of classic bike used by usertype
SELECT member_casual, COUNT(rideable_type) AS Bike_count
FROM Cyclist_year_2022
WHERE rideable_type= 'classic_bike'
GROUP BY member_casual
ORDER BY Bike_count DESC

--Nmber of docked bike used by usertype
SELECT member_casual, COUNT(rideable_type) AS Bike_count
FROM Cyclist_year_2022
WHERE rideable_type= 'docked_bike'
GROUP BY member_casual
ORDER BY Bike_count DESC

---tripduration by rideable_type per date
SELECT date, rideable_type, SUM(Trip_duration)AS trip_length
FROM Cyclist_year_2022
GROUP BY date, rideable_type
ORDER BY date, trip_length


----------------------------------------VISUALIZATION------------------------------------------

---Busiest day of the week
CREATE VIEW  Busiest_Weekday AS
  SELECT Weekday, COUNT(*) AS Weekday_count
FROM(
SELECT  started_weekday AS Weekday
FROM Cyclist_year_2022
UNION ALL
SELECT ended_weekday AS Weekday
FROM Cyclist_year_2022
)subquery_alias
GROUP BY Weekday
--ORDER BY Weekday DESC


--Top 10 most used route by casual usertype
CREATE VIEW Top_10_Route_by_casual AS
SELECT member_casual, Route_id, Route_name, start_lng, start_lat,end_lng, end_lat, COUNT(*) AS Trip_count
FROM Cyclist_year_2022
WHERE member_casual = 'casual'
GROUP BY member_casual, Route_id, Route_name, start_lng,start_lat,end_lng, end_lat
ORDER BY Trip_count DESC
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY

 --Top 10 most used route by  member usertype
 CREATE VIEW Top_10_Route_by_member AS
SELECT member_casual, Route_id, Route_name, start_lng, start_lat,end_lng, end_lat, COUNT(*) AS Trip_count
FROM Cyclist_year_2022
WHERE member_casual = 'member'
GROUP BY member_casual, Route_id, Route_name, start_lng,start_lat,end_lng, end_lat
ORDER BY Trip_count DESC
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY

--Total number of trips by date
CREATE VIEW Total_trips AS
SELECT Date,member_casual, COUNT(ride_id) AS Total_Trips
FROM Cyclist_year_2022
GROUP BY Date, member_casual
--ORDER BY Date

--Total number of trips by member
CREATE VIEW Total_trips_member AS
SELECT Date, member_casual, COUNT(member_casual) AS Total_member_Trips
FROM Cyclist_year_2022
WHERE member_casual = 'member'
GROUP BY Date, member_casual

--Total number of trips by casual
CREATE VIEW Total_trips_casual AS
SELECT Date, member_casual, COUNT(member_casual) AS Total_member_Trips
FROM Cyclist_year_2022
WHERE member_casual = 'casual'
GROUP BY Date, member_casual


--Total number of trips by weekday
CREATE VIEW Trips_weekday AS 
SELECT started_Weekday, member_casual, COUNT(ride_id) AS Total_Trips
FROM Cyclist_year_2022
GROUP BY started_Weekday, member_casual
--ORDER BY started_Weekday

---Total Route
CREATE VIEW Total_route AS
SELECT COUNT(DISTINCT Route_name) AS Route_count
FROM Cyclist_year_2022


---Total Stations
CREATE VIEW Total_Stations AS
 SELECT COUNT (DISTINCT Station_id) AS Station_count
FROM(
SELECT  start_station_id AS Station_id, start_station_name AS Station_name
FROM Cyclist_year_2022
UNION
SELECT end_station_id AS Station_id, end_station_name AS Station_name
FROM Cyclist_year_2022
)subquery_alias


---tripduration by usertype per date
CREATE VIEW Trip_duration_usertype AS
SELECT date, member_casual, SUM(Trip_duration)AS trip_length
FROM Cyclist_year_2022
GROUP BY date, member_casual
--ORDER BY date, trip_length


---tripduration by usertype weekday
CREATE VIEW Trip_duration_usertype_weekday AS
SELECT Started_weekday, member_casual, SUM(Trip_duration)AS trip_length
FROM Cyclist_year_2022
GROUP BY Started_weekday, member_casual
--ORDER BY Started_weekday, trip_length

--Bike count by rideable_type
CREATE VIEW Bike_trips AS
SELECT rideable_type, COUNT(rideable_type) AS Bike_count
FROM Cyclist_year_2022
GROUP BY rideable_type
--ORDER BY Bike_count DESC

--Nmber of electric bike used by usertype
CREATE VIEW electric_bike_trips AS
SELECT member_casual, COUNT(rideable_type) AS Bike_count
FROM Cyclist_year_2022
WHERE rideable_type= 'electric_bike'
GROUP BY member_casual
--ORDER BY Bike_count DESC

--Nmber of classic bike used by usertype
CREATE VIEW classic_bike_trips AS
SELECT member_casual, COUNT(rideable_type) AS Bike_count
FROM Cyclist_year_2022
WHERE rideable_type= 'classic_bike'
GROUP BY member_casual
--ORDER BY Bike_count DESC

--Nmber of docked bike used by usertype
CREATE VIEW docked_bike_trips AS
SELECT member_casual, COUNT(rideable_type) AS Bike_count
FROM Cyclist_year_2022
WHERE rideable_type= 'docked_bike'
GROUP BY member_casual
--ORDER BY Bike_count DESC

---tripduration by rideable_type per date
CREATE VIEW Bike_trip_length AS
SELECT date, rideable_type, SUM(Trip_duration)AS trip_length
FROM Cyclist_year_2022
GROUP BY date, rideable_type
--ORDER BY date, trip_length