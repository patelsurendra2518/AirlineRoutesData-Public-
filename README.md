 AirlineRoutesData-Public-
 # SkyRoutes Profit & Performance Analysis

A MySQL-driven data analytics project designed to evaluate airline operational performance, route profitability, capacity utilization, and temporal revenue trends using a dataset of 100,000 flight records.

---

## 📌 Project Overview

**SkyRoutes Profit & Performance Analysis** analyzes flight operational data stored in MySQL (`SkyRoutesDB`). The primary goal is to provide actionable business insights into route efficiency, financial yields, and aircraft performance by analyzing key performance metrics such as revenue, operational costs, profit margins, seat occupancy rates, and revenue efficiency per flight minute.

---

## 🗄️ Database Architecture & Setup

### Database Schema

The primary table `airline_routes` is constructed to store core flight metrics, route identifiers, geospatial coordinates, and financial figures:

```sql
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

```

### Data Ingestion

The project loads data from a CSV dataset (`AirlineRoutesData_100000.csv`) using MySQL bulk loading:

```sql
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'D:/AI_ML projects/Power_BI/SkyRoutes_Profit_Lab/01_Dataset/AirlineRoutesData_100000.csv'
INTO TABLE airline_routes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

```

---

## 🔍 Analytical Breakdown & SQL Queries

### 1. Route Volume & Operational Density

Identifies top routes by overall flight frequency:

* **Metrics:** Total Flight Count per `RouteCode`
* **Purpose:** Highlights core corridors and high-density air traffic routes.

```sql
SELECT RouteCode, COUNT(*) AS TotalFlights
FROM airline_routes
GROUP BY RouteCode
ORDER BY TotalFlights DESC
LIMIT 10;

```

---

### 2. Route Profitability & Loss Identification

Measures key financial performance across routes to isolate profitable vs. non-performing sectors:

* **Metrics:** Average Revenue, Average Operational Cost, Average Profit (`Revenue - OperationalCost`)
* **Key Scenarios:**
* Highest average profit routes.
* Negative margin routes (`HAVING AVG(Revenue - OperationalCost) < 0`) targeting routes for cost reduction or schedule optimization.



```sql
-- Top Profit Routes
SELECT 
    RouteCode,
    ROUND(AVG(Revenue), 2) AS AvgRevenue,
    ROUND(AVG(OperationalCost), 2) AS AvgCost,
    ROUND(AVG(Revenue - OperationalCost), 2) AS AvgProfit
FROM airline_routes
GROUP BY RouteCode
ORDER BY AvgProfit DESC;

```

---

### 3. Seat Occupancy & Load Factor Analysis

Evaluates how efficiently route capacity is converted into sales:

* **Formula:** $\text{Occupancy Percentage} = \left(\frac{\sum \text{Seats Sold}}{\sum \text{Seats Available}}\right) \times 100$

```sql
SELECT 
    RouteCode,
    SUM(SeatsAvailable) AS TotalSeatsAvailable,
    SUM(SeatsSold) AS TotalSeatsSold,
    ROUND((SUM(SeatsSold) / SUM(SeatsAvailable)) * 100, 2) AS OccupancyPercentage
FROM airline_routes
GROUP BY RouteCode
ORDER BY OccupancyPercentage DESC;

```

---

### 4. Monthly Financial Trends

Converts string-formatted flight dates into structured month indicators to analyze seasonal revenue growth and margin fluctuations over time:

```sql
SELECT 
    DATE_FORMAT(STR_TO_DATE(FlightDate, '%Y-%m-%d'), '%Y-%m') AS FlightMonth,
    ROUND(SUM(Revenue), 2) AS TotalRevenue,
    ROUND(SUM(OperationalCost), 2) AS TotalCost,
    ROUND(SUM(Revenue - OperationalCost), 2) AS TotalProfit
FROM airline_routes
GROUP BY FlightMonth
ORDER BY FlightMonth;

```

---

### 5. Route Type Performance Metrics

Compares financial performance across operational route classifications (e.g., Domestic, International, Regional):

```sql
SELECT 
    RouteType,
    COUNT(*) AS TotalFlights,
    ROUND(AVG(Revenue), 2) AS AvgRevenue,
    ROUND(AVG(OperationalCost), 2) AS AvgCost,
    ROUND(AVG(Revenue - OperationalCost), 2) AS AvgProfit
FROM airline_routes
GROUP BY RouteType
ORDER BY AvgProfit DESC;

```

---

### 6. Time-Efficiency & Revenue per Minute Ranking

Ranks routes based on financial yield generated per flight minute using SQL window functions (`RANK()`):

* **Formula:** $\text{Revenue Per Minute} = \frac{\text{Average Revenue}}{\text{Average Flight Duration (Mins)}}$

```sql
SELECT 
    RouteCode,
    ROUND(AVG(Revenue), 2) AS AvgRevenue,
    ROUND(AVG(FlightDurationMins), 2) AS AvgFlightDurationMins,
    ROUND(AVG(Revenue) / AVG(FlightDurationMins), 2) AS RevenuePerMinute,
    RANK() OVER (ORDER BY AVG(Revenue) / AVG(FlightDurationMins) DESC) AS RouteRank
FROM airline_routes
GROUP BY RouteCode
ORDER BY RouteRank;

```

---

## 🛠️ Prerequisites & Execution

1. **Database Platform:** MySQL Server 8.0+
2. **Setup Instructions:**
1. Create `SkyRoutesDB` in MySQL Workbench or terminal.
2. Ensure `local_infile` is enabled on both server and client configurations.
3. Update file path in the `LOAD DATA LOCAL INFILE` statement to match your local dataset location.
4. Execute `SkyRoutesAnalysis.sql` sequentially to build the structure and run data extraction queries.
