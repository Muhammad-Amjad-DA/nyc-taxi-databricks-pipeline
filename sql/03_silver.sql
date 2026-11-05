-- =============================================================
-- 03_silver.sql
-- Silver layer: cleaned and validated trips with derived columns.
--
-- Validation rules
--   * trip_distance > 0
--   * fare_amount   > 0
--   * dropoff time after pickup time
--   * trip duration between 1 and 180 minutes
-- =============================================================

CREATE OR REPLACE TABLE silver_trips AS
SELECT
    tpep_pickup_datetime                                   AS pickup_ts,
    tpep_dropoff_datetime                                  AS dropoff_ts,
    trip_distance,
    fare_amount,
    pickup_zip,
    dropoff_zip,
    (unix_timestamp(tpep_dropoff_datetime)
       - unix_timestamp(tpep_pickup_datetime)) / 60.0      AS duration_min,
    hour(tpep_pickup_datetime)                             AS pickup_hour,
    to_date(tpep_pickup_datetime)                          AS pickup_date,
    date_format(tpep_pickup_datetime, 'EEEE')              AS weekday_name,
    CASE
        WHEN dayofweek(tpep_pickup_datetime) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END                                                    AS day_type
FROM bronze_trips
WHERE trip_distance > 0
  AND fare_amount > 0
  AND tpep_dropoff_datetime > tpep_pickup_datetime
  AND (unix_timestamp(tpep_dropoff_datetime)
         - unix_timestamp(tpep_pickup_datetime)) / 60.0 BETWEEN 1 AND 180;

-- -------------------------------------------------------------
-- Data quality log: rows removed by the validation rules
-- Result: 195 of 21,932 rows removed (0.89%)
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE dq_log AS
SELECT
    current_timestamp()                     AS run_ts,
    (SELECT COUNT(*) FROM bronze_trips)     AS bronze_rows,
    (SELECT COUNT(*) FROM silver_trips)     AS silver_rows,
    (SELECT COUNT(*) FROM bronze_trips)
      - (SELECT COUNT(*) FROM silver_trips) AS rows_removed;

SELECT * FROM dq_log;
