USE SkyRoutesDB;

DROP TABLE IF EXISTS airlineroutesdata_100000;
DROP TABLE IF EXISTS airline_routes;
CREATE TABLE airline_routes (
    FlightID VARCHAR(20),
    RouteCode VARCHAR(20),
    Origin VARCHAR(10),
    Destination VARCHAR(10),
    RouteType VARCHAR(20),
    FlightDate VARCHAR(20),
    FlightDurationMins INT,
    AircraftType VARCHAR(50),
    SeatsAvailable INT,
    SeatsSold INT,
    Revenue DECIMAL(15,2),
    OperationalCost DECIMAL(15,2),
    OriginLatitude DECIMAL(10,4),
    OriginLongitude DECIMAL(10,4),
    DestinationLatitude DECIMAL(10,4),
    DestinationLongitude DECIMAL(10,4)
);

USE SkyRoutesDB;

SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'D:/AI_ML projects/Power_BI/SkyRoutes_Profit_Lab/01_Dataset/AirlineRoutesData_100000.csv'
INTO TABLE airline_routes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

USE SkyRoutesDB;
LOAD DATA LOCAL INFILE 'D:/AI_ML projects/Power_BI/SkyRoutes_Profit_Lab/01_Dataset/AirlineRoutesData_100000.csv'
INTO TABLE airline_routes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) AS TotalRecords
FROM airline_routes;

SELECT 
    RouteCode,
    COUNT(*) AS TotalFlights
FROM airline_routes
GROUP BY RouteCode
ORDER BY TotalFlights DESC
LIMIT 10;

SELECT
    RouteCode,
    ROUND(AVG(Revenue), 2) AS AvgRevenue,
    ROUND(AVG(OperationalCost), 2) AS AvgCost,
    ROUND(AVG(Revenue - OperationalCost), 2) AS AvgProfit
FROM airline_routes
GROUP BY RouteCode
ORDER BY AvgProfit DESC;


SELECT
    RouteCode,
    ROUND(AVG(Revenue), 2) AS AvgRevenue,
    ROUND(AVG(OperationalCost), 2) AS AvgCost,
    ROUND(AVG(Revenue - OperationalCost), 2) AS AvgProfit
FROM airline_routes
GROUP BY RouteCode
HAVING AVG(Revenue - OperationalCost) < 0
ORDER BY AvgProfit ASC;

SELECT
    RouteCode,
    SUM(SeatsAvailable) AS TotalSeatsAvailable,
    SUM(SeatsSold) AS TotalSeatsSold,
    ROUND(
        (SUM(SeatsSold) / SUM(SeatsAvailable)) * 100,
        2
    ) AS OccupancyPercentage
FROM airline_routes
GROUP BY RouteCode
ORDER BY OccupancyPercentage DESC;


SELECT
    DATE_FORMAT(STR_TO_DATE(FlightDate, '%Y-%m-%d'), '%Y-%m') AS FlightMonth,
    ROUND(SUM(Revenue), 2) AS TotalRevenue,
    ROUND(SUM(OperationalCost), 2) AS TotalCost,
    ROUND(SUM(Revenue - OperationalCost), 2) AS TotalProfit
FROM airline_routes
GROUP BY FlightMonth
ORDER BY FlightMonth;


SELECT
    RouteType,
    COUNT(*) AS TotalFlights,
    ROUND(AVG(Revenue), 2) AS AvgRevenue,
    ROUND(AVG(OperationalCost), 2) AS AvgCost,
    ROUND(AVG(Revenue - OperationalCost), 2) AS AvgProfit
FROM airline_routes
GROUP BY RouteType
ORDER BY AvgProfit DESC;


SELECT
    RouteCode,
    ROUND(AVG(Revenue), 2) AS AvgRevenue,
    ROUND(AVG(FlightDurationMins), 2) AS AvgFlightDurationMins,
    ROUND(
        AVG(Revenue) / AVG(FlightDurationMins),
        2
    ) AS RevenuePerMinute,
    RANK() OVER (
        ORDER BY AVG(Revenue) / AVG(FlightDurationMins) DESC
    ) AS RouteRank
FROM airline_routes
GROUP BY RouteCode
ORDER BY RouteRank;
