-- Flatten a self-referential hierarchy into level + path columns
-- ---------------------------------------------------------------------------
-- A metric view can roll up FIXED-depth hierarchies with joins (see Hierarchies.yml).
-- For an ARBITRARY-depth, self-referential tree (node_id -> parent_id: org charts,
-- category trees, bills-of-materials) the depth is unknown, so flatten the tree ONCE
-- with a recursive CTE into a normalized dimension carrying `root_id`, `level`, and a
-- materialized `path`. Join your facts to that dimension and reuse the same
-- window-over-aggregate rollup / share-of-parent measures at any depth.
--
-- Runs on current Databricks SQL — WITH RECURSIVE is supported (validated on serverless;
-- requires a runtime/SQL channel with recursive-CTE support). The identical query runs on
-- Lakebase (Postgres); there you can type `path` as ltree for native subtree operators (<@, ~).
-- ---------------------------------------------------------------------------

-- Sample self-referential hierarchy (replace with your own node/parent table).
CREATE OR REPLACE TEMP VIEW hierarchy AS
SELECT * FROM VALUES
    (1, CAST(NULL AS INT), 'All Products'),
    (2, 1,   'Beverages'),
    (3, 1,   'Food'),
    (4, 2,   'Coffee'),
    (5, 2,   'Tea'),
    (6, 4,   'Espresso'),
    (7, 3,   'Dairy')
AS hierarchy(node_id, parent_id, name);

-- Recursive flatten: anchor = roots (no parent); recursive term descends, carrying the
-- root, incrementing level, and appending to a dotted ancestor path.
WITH RECURSIVE tree AS (
    SELECT
        node_id,
        parent_id,
        node_id                            AS root_id,
        0                                  AS level,
        CAST(node_id AS STRING)            AS path
    FROM hierarchy
    WHERE parent_id IS NULL

    UNION ALL

    SELECT
        c.node_id,
        c.parent_id,
        t.root_id,
        t.level + 1                        AS level,
        t.path || '.' || CAST(c.node_id AS STRING) AS path
    FROM hierarchy c
    JOIN tree t ON c.parent_id = t.node_id
)
SELECT node_id, parent_id, root_id, level, path
FROM tree
ORDER BY path;

-- Result:
--   node_id | parent_id | root_id | level | path
--   1       | NULL      | 1       | 0     | 1
--   2       | 1         | 1       | 1     | 1.2
--   4       | 2         | 1       | 2     | 1.2.4
--   6       | 4         | 1       | 3     | 1.2.4.6
--   5       | 2         | 1       | 2     | 1.2.5
--   3       | 1         | 1       | 1     | 1.3
--   7       | 3         | 1       | 2     | 1.3.7
--
-- Then materialize as a dimension (CREATE TABLE hierarchy_flat AS <above>), join your
-- fact to it on node_id, and in the metric view:
--   * branch rollup     : SUM(SUM(measure)) OVER (PARTITION BY `RootId`)
--   * subtree filter    : WHERE path = '1.2' OR path LIKE '1.2.%'   (Lakebase ltree: path <@ '1.2')
--                         both forms include the subtree ROOT node (1.2) plus its descendants;
--                         a bare LIKE '1.2.%' would drop the root, so keep the `= '1.2' OR` term.
--   * drill to depth N   : WHERE level = N
-- reusing the exact rollup / share-of-parent measures from Hierarchies.yml.
