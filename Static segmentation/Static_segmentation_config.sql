-- =====================================================================================================================
-- Mock segmentation configuration table
--
-- This table externalizes the price-band boundaries that the CASE-based patterns hard-code inside the metric view
-- (see Static_segmentation.yml). The metric view Static_segmentation_config.yml range-joins orders to this
-- table instead of embedding a CASE expression, so the bands can be edited as data without touching the definition.
--
-- Boundary convention: min_price is INCLUSIVE, max_price is EXCLUSIVE  (min_price <= o_totalprice < max_price).
-- The top band leaves max_price NULL to mean "no upper bound".
-- Prerequisite: run tpc-h.sql first (creates uc_semantics_patterns.tpch).
-- =====================================================================================================================


-- =====================================================================================================================
-- 1. Global price bands - one set of boundaries applied to every order
-- =====================================================================================================================

CREATE OR REPLACE TABLE price_segment_range (
    segment_name  STRING            NOT NULL,
    segment_sort  INT               NOT NULL,
    min_price     DECIMAL(18, 2)    NOT NULL,
    max_price     DECIMAL(18, 2)          -- NULL = open-ended top band
);

INSERT INTO price_segment_range (segment_name, segment_sort, min_price, max_price) VALUES
    ('VERY LOW', 1,      0.00,  50000.00),
    ('LOW',      2,  50000.00, 150000.00),
    ('MEDIUM',   3, 150000.00, 300000.00),
    ('HIGH',     4, 300000.00,      NULL);


