-- =============================================================
-- 02_bronze.sql
-- Bronze layer: raw copy of the source data, unchanged,
-- plus an ingestion timestamp for traceability.
-- Source: samples.nyctaxi.trips (Databricks sample dataset)
-- =============================================================

CREATE OR REPLACE TABLE bronze_trips AS
SELECT
    *,
    current_timestamp() AS ingested_at
FROM samples.nyctaxi.trips;

-- Check: 21,932 rows
SELECT COUNT(*) AS bronze_rows
FROM bronze_trips;
