-- =====================================================================================================================
-- 1. Create test catalog and schema
-- =====================================================================================================================

CREATE CATALOG IF NOT EXISTS uc_semantics_patterns;
USE CATALOG uc_semantics_patterns;

CREATE SCHEMA IF NOT EXISTS tpcds;
USE SCHEMA tpcds;


-- =====================================================================================================================
-- 2. Create test tables
-- =====================================================================================================================

CREATE OR REPLACE TABLE call_center AS SELECT * FROM samples.tpcds_sf1.call_center;
CREATE OR REPLACE TABLE catalog_page AS SELECT * FROM samples.tpcds_sf1.catalog_page;
CREATE OR REPLACE TABLE catalog_returns AS SELECT * FROM samples.tpcds_sf1.catalog_returns;
CREATE OR REPLACE TABLE catalog_sales AS SELECT * FROM samples.tpcds_sf1.catalog_sales;
CREATE OR REPLACE TABLE customer AS SELECT * FROM samples.tpcds_sf1.customer;
CREATE OR REPLACE TABLE customer_address AS SELECT * FROM samples.tpcds_sf1.customer_address;
CREATE OR REPLACE TABLE customer_demographics AS SELECT * FROM samples.tpcds_sf1.customer_demographics;
CREATE OR REPLACE TABLE date_dim AS SELECT * FROM samples.tpcds_sf1.date_dim;
CREATE OR REPLACE TABLE household_demographics AS SELECT * FROM samples.tpcds_sf1.household_demographics;
CREATE OR REPLACE TABLE income_band AS SELECT * FROM samples.tpcds_sf1.income_band;
CREATE OR REPLACE TABLE inventory AS SELECT * FROM samples.tpcds_sf1.inventory;
CREATE OR REPLACE TABLE item AS SELECT * FROM samples.tpcds_sf1.item;
CREATE OR REPLACE TABLE promotion AS SELECT * FROM samples.tpcds_sf1.promotion;
CREATE OR REPLACE TABLE reason AS SELECT * FROM samples.tpcds_sf1.reason;
CREATE OR REPLACE TABLE ship_mode AS SELECT * FROM samples.tpcds_sf1.ship_mode;
CREATE OR REPLACE TABLE store AS SELECT * FROM samples.tpcds_sf1.store;
CREATE OR REPLACE TABLE store_returns AS SELECT * FROM samples.tpcds_sf1.store_returns;
CREATE OR REPLACE TABLE store_sales AS SELECT * FROM samples.tpcds_sf1.store_sales;
CREATE OR REPLACE TABLE time_dim AS SELECT * FROM samples.tpcds_sf1.time_dim;
CREATE OR REPLACE TABLE warehouse AS SELECT * FROM samples.tpcds_sf1.warehouse;
CREATE OR REPLACE TABLE web_page AS SELECT * FROM samples.tpcds_sf1.web_page;
CREATE OR REPLACE TABLE web_returns AS SELECT * FROM samples.tpcds_sf1.web_returns;
CREATE OR REPLACE TABLE web_sales AS SELECT * FROM samples.tpcds_sf1.web_sales;
CREATE OR REPLACE TABLE web_site AS SELECT * FROM samples.tpcds_sf1.web_site;


CREATE OR REPLACE TABLE inventory_daily AS
WITH
-- Get date boundaries from inventory
date_bounds AS (
  SELECT min(inv_date_sk) AS min_sk, max(inv_date_sk) AS max_sk
  FROM inventory
),
-- All daily dates within the inventory range
date_spine AS (
  SELECT d.d_date_sk, d.d_date
  FROM date_dim d
  JOIN date_bounds b ON d.d_date_sk BETWEEN b.min_sk AND b.max_sk
),
-- All distinct (item, warehouse) combinations
entities AS (
  SELECT DISTINCT inv_item_sk, inv_warehouse_sk
  FROM inventory
),
-- Full daily skeleton: every date × every (item, warehouse)
skeleton AS (
  SELECT
    d.d_date_sk,
    d.d_date,
    e.inv_item_sk,
    e.inv_warehouse_sk
  FROM date_spine d
  CROSS JOIN entities e
),
-- Join actual inventory values (only present on weekly dates)
with_actuals AS (
  SELECT
    s.d_date_sk,
    s.d_date,
    s.inv_item_sk,
    s.inv_warehouse_sk,
    i.inv_quantity_on_hand
  FROM skeleton s
  LEFT JOIN inventory i
    ON s.d_date_sk = i.inv_date_sk
    AND s.inv_item_sk = i.inv_item_sk
    AND s.inv_warehouse_sk = i.inv_warehouse_sk
)
-- Forward-fill: replicate last known quantity into gap days
SELECT
  d_date_sk as inv_date_sk,
  inv_item_sk,
  inv_warehouse_sk,
  LAST_VALUE(inv_quantity_on_hand, true)
    OVER (PARTITION BY inv_item_sk, inv_warehouse_sk ORDER BY d_date_sk
          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
    AS inv_quantity_on_hand,
  LAST_VALUE(inv_quantity_on_hand, true)
    OVER (PARTITION BY inv_item_sk, inv_warehouse_sk ORDER BY d_date_sk
          ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING)
    AS inv_quantity_on_hand_prev_day
FROM with_actuals;

