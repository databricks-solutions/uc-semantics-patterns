# :evergreen_tree: Hierarchies

## Introduction

Business data is full of **parent-child hierarchies**: geographies (region → country → customer), org charts (manager → report), product taxonomies, chart-of-accounts, and bills-of-materials. The recurring analytical questions are *rollup* ("what's the total for this branch?") and *share-of-parent* ("what fraction of its region does this country contribute?").

This group of patterns shows how to express those directly in a [Unity Catalog semantics](https://docs.databricks.com/aws/en/business-semantics/) metric view, in two flavors:

- **Fixed-depth hierarchies** — the levels are known columns you already join to (region → country → customer). Rollups and share-of-parent are `window-function-over-aggregate` measures, exactly like the [Ranking](../Ranking/) patterns — no extra tables required.
- **Arbitrary-depth / ragged, self-referential hierarchies** — a single table where each row points at its parent (`parent_id`). You can't join a fixed number of levels, so you *flatten the tree once* with a recursive CTE into level/path columns, then the metric view rolls up on those. See [Self-referential hierarchies](#self-referential-hierarchies--arbitrary-depth-trees) below.

## Preparation

1. Ensure that you have created the test dataset using the [tpc-h.sql](/tpc-h.sql) script.

2. Create the basic metric view definition. The full definition is in [`Hierarchies.yml`](./Hierarchies.yml); the base `Revenue` measure and the region → country → customer join hierarchy every pattern below builds on are shown here.
    <details>
    <summary>Basic metric view definition</summary>

    ```yaml
    version: 1.1
    comment: Unity Catalog semantics patterns

    source: orders

    joins:
      - name: customer
        source: customer
        'on': source.o_custkey = customer.c_custkey
        rely:
          at_most_one_match: true
        joins:
          - name: nation
            source: nation
            'on': customer.c_nationkey = nation.n_nationkey
            rely:
              at_most_one_match: true
            joins:
              - name: region
                source: region
                'on': nation.n_regionkey = region.r_regionkey
                rely:
                  at_most_one_match: true

    fields:
      - name: RegionName
        display_name: Region Name
        expr: customer.nation.region.r_name
      - name: CountryName
        display_name: Country Name
        expr: customer.nation.n_name
      - name: CustomerName
        display_name: Customer Name
        expr: customer.c_name

    measures:
      - name: Revenue
        display_name: Revenue
        expr: SUM(o_totalprice)
    ```

    </details>


## Parent subtotals — roll a leaf measure up to an ancestor level

**Sample question** — *Show each country's revenue, but carry its region's total on the same row so I can see the branch subtotal while drilling down.*

**Why it matters** — A drill-down table usually loses the parent's total once you expand it. A rollup measure repeats the ancestor-level aggregate on every descendant row, so the subtotal travels with the detail — no separate query, no client-side maths.

> [!NOTE]
> `SUM(SUM(measure)) OVER (PARTITION BY <ancestor levels>)` is the key: the inner `SUM` is the metric view's own per-row aggregate, and the outer windowed `SUM` re-aggregates it up to the partition (the ancestor). This respects whatever `WHERE`/`GROUP BY` the query applies.

### Measure definition

```yaml
- name: RevenueRegionSubtotal
  display_name: Revenue — Region Subtotal
  expr: SUM(SUM(o_totalprice)) OVER (PARTITION BY `RegionName`)

- name: RevenueCountrySubtotal
  display_name: Revenue — Country Subtotal
  expr: SUM(SUM(o_totalprice)) OVER (PARTITION BY `RegionName`, `CountryName`)
```

## Share-of-parent — a level's contribution to its ancestor

**Sample question** — *What share of its region does each country contribute, and what share of the whole business?*

**Why it matters** — Share-of-parent turns raw subtotals into "how much of the branch is this?" — the ratio leaders actually compare. The denominator is the parent subtotal from the pattern above, so children under one parent always sum to 100%.

### Measure definition

```yaml
- name: PctOfRegion
  display_name: % of Region
  expr: SUM(o_totalprice) / NULLIF(SUM(SUM(o_totalprice)) OVER (PARTITION BY `RegionName`), 0)

- name: PctOfCountry
  display_name: % of Country
  expr: SUM(o_totalprice) / NULLIF(SUM(SUM(o_totalprice)) OVER (PARTITION BY `RegionName`, `CountryName`), 0)

- name: PctOfTotal
  display_name: % of Total
  expr: SUM(o_totalprice) / NULLIF(SUM(SUM(o_totalprice)) OVER (), 0)
```

> [!TIP]
> `NULLIF(..., 0)` guards the divide-by-zero when a filter empties a parent partition.

### Test query & output

Query the metric view at **region → country** grain. Measures are wrapped in `AGG(...)`; dimensions are selected bare (the repo-wide convention):

```sql
SELECT
  RegionName,
  CountryName,
  AGG(Revenue),
  AGG(RevenueRegionSubtotal),
  AGG(PctOfRegion),
  AGG(PctOfTotal)
FROM mv_Hierarchies
GROUP BY ALL
ORDER BY RegionName, AGG(Revenue) DESC
```

| RegionName | CountryName | Revenue | RevenueRegionSubtotal | PctOfRegion | PctOfTotal |
| --- | --- | ---: | ---: | ---: | ---: |
| AFRICA | ETHIOPIA | 45,602,005,018 | 225,347,326,876 | 0.2024 | 0.0402 |
| AFRICA | MOZAMBIQUE | 45,121,731,743 | 225,347,326,876 | 0.2002 | 0.0398 |
| AFRICA | ALGERIA | 44,997,918,062 | 225,347,326,876 | 0.1997 | 0.0397 |
| AFRICA | KENYA | 44,891,385,482 | 225,347,326,876 | 0.1992 | 0.0396 |
| AFRICA | MOROCCO | 44,734,286,571 | 225,347,326,876 | 0.1985 | 0.0395 |

The five `PctOfRegion` values under AFRICA sum to `1.0000` — every child sums to its parent — and `PctOfTotal` is each country's share of the grand total.

> [!IMPORTANT]
> A rollup measure is only meaningful when its partition spans **more than one** query row. At the region → country grain above, `RevenueRegionSubtotal` / `PctOfRegion` / `PctOfTotal` work because a region (and the total) contains many countries. The **country-level** measures (`RevenueCountrySubtotal`, `PctOfCountry`) need a *finer* grain than country — otherwise each country partition holds a single row, so the subtotal equals `Revenue` and `PctOfCountry` = 1.0. Drill to **customer** grain to see them work:

```sql
SELECT
  CountryName,
  CustomerName,
  AGG(Revenue),
  AGG(RevenueCountrySubtotal),
  AGG(PctOfCountry)
FROM mv_Hierarchies
WHERE CountryName = 'BRAZIL'
GROUP BY ALL
ORDER BY AGG(Revenue) DESC
```

| CountryName | CustomerName | Revenue | RevenueCountrySubtotal | PctOfCountry |
| --- | --- | ---: | ---: | ---: |
| BRAZIL | Customer#000172696 | 6,326,976 | 45,292,664,787 | 0.0001 |
| BRAZIL | Customer#000020551 | 6,191,793 | 45,292,664,787 | 0.0001 |
| BRAZIL | Customer#000117991 | 6,090,945 | 45,292,664,787 | 0.0001 |

Each customer's `PctOfCountry` is its share of BRAZIL's country subtotal (`45,292,664,787`, itself the BRAZIL row of the region query above); across all of BRAZIL's customers they sum to 1.0.

## Self-referential hierarchies — arbitrary-depth trees

Fixed joins work when the depth is known. For a table that points at itself (`id`, `parent_id`) — org charts, category trees, bills-of-materials — the depth is variable, so you flatten the tree **once** with a recursive CTE into a normalized dimension (a stable `path` and a `level`), then point a metric view at that dimension and reuse the exact rollup / share-of-parent measures above.

See [`hierarchy_flatten.sql`](./hierarchy_flatten.sql) for the recursive-CTE flattener. It produces one row per node with:

- `root_id` / `level` — so `PARTITION BY root_id` rolls a whole branch up, and `level` filters to a drill depth;
- `path` — a materialized ancestor path (an [`ltree`](https://www.postgresql.org/docs/current/ltree.html) value on Lakebase, or a delimited string on the lakehouse) for prefix/subtree filtering.

Once flattened, the hierarchy behaves like the fixed-depth case: `SUM(SUM(measure)) OVER (PARTITION BY <ancestor id>)` gives branch subtotals, and dividing by it gives share-of-parent — identical to the patterns above, now at any depth.
