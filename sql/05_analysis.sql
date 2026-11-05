-- =============================================================
-- 05_analysis.sql
-- Business questions answered from the Gold tables.
-- =============================================================

-- Q1. Which hours have the most trips and revenue? -------------
SELECT pickup_hour, trips, total_fare, avg_fare
FROM gold_hourly_demand
ORDER BY pickup_hour;

-- Q2. Daily revenue trend with 7-day moving average ------------
SELECT pickup_date, daily_revenue, moving_avg_7d
FROM gold_daily_revenue
ORDER BY pickup_date;

-- Q3. Key statistics behind the findings -----------------------
SELECT 'busiest hour' AS metric,
       CONCAT(pickup_hour, ':00 with ', trips, ' trips') AS value
FROM (SELECT * FROM gold_hourly_demand ORDER BY trips DESC LIMIT 1)

UNION ALL
SELECT 'quietest hour',
       CONCAT(pickup_hour, ':00 with ', trips, ' trips')
FROM (SELECT * FROM gold_hourly_demand ORDER BY trips ASC LIMIT 1)

UNION ALL
SELECT 'top pickup zip',
       CONCAT(pickup_zip, ' with ', trips, ' trips (', pct_of_all_trips, '% of all)')
FROM gold_top_pickup_zips
WHERE trip_rank = 1

UNION ALL
SELECT 'top 5 zips share of trips',
       CONCAT(ROUND(SUM(pct_of_all_trips), 1), '%')
FROM gold_top_pickup_zips
WHERE trip_rank <= 5

UNION ALL
SELECT 'lowest revenue day',
       CONCAT(pickup_date, ' revenue ', daily_revenue, ' trips ', trips)
FROM (SELECT * FROM gold_daily_revenue ORDER BY daily_revenue ASC LIMIT 1)

UNION ALL
SELECT 'highest revenue day',
       CONCAT(pickup_date, ' revenue ', daily_revenue, ' trips ', trips)
FROM (SELECT * FROM gold_daily_revenue ORDER BY daily_revenue DESC LIMIT 1)

UNION ALL
SELECT 'avg daily revenue',
       CAST(ROUND(AVG(daily_revenue), 2) AS STRING)
FROM gold_daily_revenue

UNION ALL
SELECT distance_band,
       CONCAT(trips, ' trips, avg fare ', avg_fare,
              ', fare/mile ', avg_fare_per_mile, ', ', avg_duration_min, ' min')
FROM gold_distance_bands

UNION ALL
SELECT 'rows removed',
       CONCAT(rows_removed, ' of ', bronze_rows,
              ' (', ROUND(100.0 * rows_removed / bronze_rows, 2), '%)')
FROM dq_log;
