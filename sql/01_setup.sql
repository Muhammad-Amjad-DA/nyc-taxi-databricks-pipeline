-- =============================================================
-- 01_setup.sql
-- Creates the project schema that holds every pipeline table.
-- =============================================================

USE CATALOG workspace;

CREATE SCHEMA IF NOT EXISTS nyc_taxi_pipeline;

USE SCHEMA nyc_taxi_pipeline;
