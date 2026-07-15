-- =====================================================================================================================
-- 1. Create test catalog and schema
-- =====================================================================================================================

CREATE CATALOG IF NOT EXISTS uc_semantics_patterns;
USE CATALOG uc_semantics_patterns;

CREATE SCHEMA IF NOT EXISTS tpch;
USE SCHEMA tpch;


-- =====================================================================================================================
-- 2. Create test tables
-- =====================================================================================================================

CREATE OR REPLACE TABLE customer AS SELECT * FROM samples.tpch.customer;
CREATE OR REPLACE TABLE lineitem AS SELECT * FROM samples.tpch.lineitem; 
CREATE OR REPLACE TABLE nation AS SELECT * FROM samples.tpch.nation;
CREATE OR REPLACE TABLE orders AS SELECT * FROM samples.tpch.orders;
CREATE OR REPLACE TABLE part AS SELECT * FROM samples.tpch.part;
CREATE OR REPLACE TABLE partsupp AS SELECT * FROM samples.tpch.partsupp;
CREATE OR REPLACE TABLE region AS SELECT * FROM samples.tpch.region;
CREATE OR REPLACE TABLE supplier AS SELECT * FROM samples.tpch.supplier;


-- =====================================================================================================================
-- 2. Create PK/FK constraints
-- =====================================================================================================================

ALTER TABLE nation ALTER COLUMN n_nationkey SET NOT NULL;
ALTER TABLE region ALTER COLUMN r_regionkey SET NOT NULL;
ALTER TABLE part ALTER COLUMN p_partkey SET NOT NULL;
ALTER TABLE supplier ALTER COLUMN s_suppkey SET NOT NULL;
ALTER TABLE partsupp ALTER COLUMN ps_partkey SET NOT NULL;
ALTER TABLE partsupp ALTER COLUMN ps_suppkey SET NOT NULL;
ALTER TABLE customer ALTER COLUMN c_custkey SET NOT NULL;
ALTER TABLE orders ALTER COLUMN o_orderkey SET NOT NULL;
ALTER TABLE lineitem ALTER COLUMN l_orderkey SET NOT NULL;
ALTER TABLE lineitem ALTER COLUMN l_linenumber SET NOT NULL;

ALTER TABLE nation ADD CONSTRAINT pk_nation PRIMARY KEY(n_nationkey) RELY;
ALTER TABLE region ADD CONSTRAINT pk_region PRIMARY KEY(r_regionkey) RELY;
ALTER TABLE part ADD CONSTRAINT pk_part PRIMARY KEY(p_partkey) RELY;
ALTER TABLE supplier ADD CONSTRAINT pk_supplier PRIMARY KEY(s_suppkey) RELY;
ALTER TABLE partsupp ADD CONSTRAINT pk_partsupp PRIMARY KEY(ps_partkey, ps_suppkey) RELY;
ALTER TABLE customer ADD CONSTRAINT pk_customer PRIMARY KEY(c_custkey) RELY;
ALTER TABLE orders ADD CONSTRAINT pk_orders PRIMARY KEY(o_orderkey) RELY;
ALTER TABLE lineitem ADD CONSTRAINT pk_lineitem PRIMARY KEY(l_orderkey, l_linenumber) RELY;

ALTER TABLE nation ADD CONSTRAINT fk_region FOREIGN KEY(n_regionkey) REFERENCES region NOT ENFORCED RELY;
ALTER TABLE customer ADD CONSTRAINT fk_nation FOREIGN KEY(c_nationkey) REFERENCES nation NOT ENFORCED RELY;
ALTER TABLE orders ADD CONSTRAINT fk_customer FOREIGN KEY(o_custkey) REFERENCES customer NOT ENFORCED RELY;
ALTER TABLE lineitem ADD CONSTRAINT fk_orders FOREIGN KEY(l_orderkey) REFERENCES orders NOT ENFORCED RELY;
ALTER TABLE lineitem ADD CONSTRAINT fk_parts FOREIGN KEY(l_partkey) REFERENCES part NOT ENFORCED RELY;
ALTER TABLE lineitem ADD CONSTRAINT fk_supplier FOREIGN KEY(l_suppkey) REFERENCES supplier NOT ENFORCED RELY;
ALTER TABLE partsupp ADD CONSTRAINT fk_partsupp_part FOREIGN KEY(ps_partkey) REFERENCES part NOT ENFORCED RELY;
ALTER TABLE partsupp ADD CONSTRAINT fk_part_suppsupplier FOREIGN KEY(ps_suppkey) REFERENCES supplier NOT ENFORCED RELY;