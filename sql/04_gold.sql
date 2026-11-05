-- =============================================================
-- 04_gold.sql
-- Gold layer: analysis-ready summary tables.
-- =============================================================

-- 4a. Hourly demand -------------------------------------------
CREATE OR REPLACE TABLE gold_hourly_demand AS
SELECT
    pickup_hour,
    COUNT(*)                    AS trips,
    ROUND(SUM(fare_amount), 2)  AS total_fare,
    ROUND(AVG(fare_amount), 2)  AS avg_fare
FROM silver_trips
GROUP BY pickup_hour;

-- 4b. Daily revenue, running total and 7-day moving average ---
CREATE OR REPLACE TABLE gold_daily_revenue AS
WITH daily AS (
    SELECT
        pickup_date,
        SUM(fare_amount) AS daily_revenue,
        COUNT(*)         AS trips
    FROM silver_trips
    GROUP BY pickup_date
)
SELECT
    pickup_date,
    trips,
    ROUND(daily_revenue, 2) AS daily_revenue,
    ROUND(SUM(daily_revenue) OVER (ORDER BY pickup_date), 2) AS running_total,
    ROUND(AVG(daily_revenue) OVER (
        ORDER BY pickup_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2)        AS moving_avg_7d
FROM daily;

-- 4c. Pickup ZIP codes ranked by trips, with share of total ---
CREATE OR REPLACE TABLE gold_top_pickup_zips AS
WITH zip_stats AS (
    SELECT
        pickup_zip,
        COUNT(*)         AS trips,
        SUM(fare_amount) AS total_fare
    FROM silver_trips
    GROUP BY pickup_zip
)
SELECT
    RANK() OVER (ORDER BY trips DESC)            AS trip_rank,
    pickup_zip,
    trips,
    ROUND(total_fare, 2)                         AS total_fare,
    ROUND(100.0 * trips / SUM(trips) OVER (), 2) AS pct_of_all_trips
FROM zip_stats;

-- 4d. Fare behaviour by distance band -------------------------
CREATE OR REPLACE TABLE gold_distance_bands AS
SELECT
    CASE
        WHEN trip_distance < 1  THEN '1) Under 1 mile'
        WHEN trip_distance < 3  THEN '2) 1-3 miles'
        WHEN trip_distance < 6  THEN '3) 3-6 miles'
        WHEN trip_distance < 10 THEN '4) 6-10 miles'
        ELSE                         '5) 10+ miles'
    END                                        AS distance_band,
    COUNT(*)                                   AS trips,
    ROUND(AVG(fare_amount), 2)                 AS avg_fare,
    ROUND(AVG(fare_amount / trip_distance), 2) AS avg_fare_per_mile,
    ROUND(AVG(duration_min), 1)                AS avg_duration_min
FROM silver_trips
GROUP BY 1;

-- -------------------------------------------------------------
-- Validation: row count of every layer
-- bronze 21,932 | silver 21,737 | hourly 24 | daily 60
-- zips 118 | distance bands 5
-- -------------------------------------------------------------
SELECT 'bronze_trips'         AS table_name, COUNT(*) AS row_count FROM bronze_trips
UNION ALL SELECT 'silver_trips',         COUNT(*) FROM silver_trips
UNION ALL SELECT 'gold_hourly_demand',   COUNT(*) FROM gold_hourly_demand
UNION ALL SELECT 'gold_daily_revenue',   COUNT(*) FROM gold_daily_revenue
UNION ALL SELECT 'gold_top_pickup_zips', COUNT(*) FROM gold_top_pickup_zips
UNION ALL SELECT 'gold_distance_bands',  COUNT(*) FROM gold_distance_bands;
