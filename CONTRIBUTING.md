# Contributing

This repository is maintained by Databricks and intended for contributions from Databricks Field Engineers. While the repository is public and meant to help anyone developing projects that use Databricks, external contributions are not currently accepted. Feel free to open an issue with requests or suggestions.


## Project layout

```
.
├── README.md                            # Top-level overview and table of contents
├── CONTRIBUTING.md                      # This file
├── CHANGELOG.md                         # Release notes
├── LICENSE.md, NOTICE.md, SECURITY.md   # Legal and security policy
├── CODEOWNERS                           # GitHub code owners
├── tpc-h.sql                            # TPC-H test dataset setup script
├── tpc-ds.sql                           # TPC-DS test dataset setup script
├── Time Intelligence/                   # Time Intelligence patterns
│   ├── README.md                        # Domain overview and TOC
│   ├── Period-to-date totals/           # YTD, QTD, MTD
│   ├── Period-over-period growth/       # YoY, QoQ, MoM, WoW
│   ├── Period-to-date growth/           # YOYTD, QOQTD, MOMTD, WOWTD
│   └── Moving calculations/             # Rolling/trailing window totals and averages
└── Semi-additive calculations/          # Opening/closing balances, first/last date values
```


## New domains

### Folder structure

When adding a new pattern domain, use the [README template](#readme-template) at the bottom of this document as a starting point.

Every new domain folder should contain:
- `README.md` describing the patterns.
- A `*.yml` file with the end-to-end metric view definition.
- A `*.sql` file, if additional SQL objects are required.
- An `images/` folder containing screenshots and other images used in `README.md`.


### README structure

README files should follow this structure:

- **Introduction** — the domain overview.
- **Preparation** — prerequisites or steps required to create an initial setup. Usually includes creating the test dataset (UC catalog/schema) and the basic metric view definition.
- **Code patterns** — for every pattern, add a top-level section with the following subsections:
    - ***Scenario / Introduction*** — an explanation of the scenario in non-technical language, including the **Sample question**.
    - ***Measure definition*** — the YAML definition of the respective measure.
    - ***Test query*** — a runnable SQL query and its expected output.
- **End-to-end template** — a link to the complete YAML file.

Screenshots of test query output should be rendered with a fixed display width so they remain legible on GitHub:

```html
<img width="600" src="./images/<screenshot>.png" alt="Test query output" />
```


## Key development principles

- Test datasets are based on TPC-H (preferred) or TPC-DS.
- If additional SQL objects are required, provide a separate SQL script that creates them.
- SQL scripts should be idempotent (`CREATE OR REPLACE`, `IF NOT EXISTS`, etc.).
- For every measure/field, specify `display_name` when the raw name is not user-friendly.
- For every measure that will be consumed by users or applications, specify:
    - `display_name` - a user-friendly name of the measure.    
    - `comment` — elaborate on the semantics of the measure.
    - `format` — user-friendly formatting for the measure.
- For intermediate measures:
    - `display_name` - *optional*, a user-friendly name of the measure.    
    - `comment` — *optional*, specify only when it helps understand the calculation logic.
    - `format` — *optional*, user-friendly formatting for the measure.
- Within a YAML list item, order the top-level keys as `name`, `display_name`, `comment`, then everything else in a natural reading order (`expr`, `window`, `format`, …).
- Preferred formatting:
    - Currency measures — `$1,234,567.90` / `-$1,234,567.90`
    - Quantity measures:
        - Decimal numbers — `1,234,567.90` / `-1,234,567.90`
        - Whole numbers — `1,234,567` / `-1,234,567`
- Where applicable, reference a common industry pattern (e.g., from [daxpatterns.com](https://www.daxpatterns.com/)), followed by a code example and a step-by-step walkthrough.


### Naming conventions

| Acronym | Description                                                          |
| ------- | -------------------------------------------------------------------- |
| YTD     | Year-to-date                                                         |
| QTD     | Quarter-to-date                                                      |
| MTD     | Month-to-date                                                        |
| WTD     | Week-to-date                                                         |
| MAT     | Moving annual total                                                  |
| PY      | Previous year                                                        |
| PQ      | Previous quarter                                                     |
| PM      | Previous month                                                       |
| PW      | Previous week                                                        |
| PYC     | Previous year complete                                               |
| PQC     | Previous quarter complete                                            |
| PMC     | Previous month complete                                              |
| PP      | Previous period (automatically selects year, quarter, or month)      |
| PYMAT   | Previous year moving annual total                                    |
| YoY     | Year-over-year                                                       |
| QoQ     | Quarter-over-quarter                                                 |
| MoM     | Month-over-month                                                     |
| WoW     | Week-over-week                                                       |
| MATG    | Moving annual total growth                                           |
| PoP     | Period-over-period (automatically selects year, quarter, or month)   |
| PYTD    | Previous year-to-date                                                |
| PQTD    | Previous quarter-to-date                                             |
| PMTD    | Previous month-to-date                                               |
| PWTD    | Previous week-to-date                                                |
| YOYTD   | Year-over-year-to-date                                               |
| QOQTD   | Quarter-over-quarter-to-date                                         |
| MOMTD   | Month-over-month-to-date                                             |
| WOWTD   | Week-over-week-to-date                                               |

Metric view names in test queries should use `mv_<PatternName>` in PascalCase (e.g., `mv_PeriodToDateTotals`, `mv_MovingCalculations`).


## Pull requests

- Reference the customer UCO or use case in the PR description when possible.
- Keep the diff focused. Mechanical reorgs and logic changes should land in separate commits.
- Update [CHANGELOG.md](./CHANGELOG.md) under `## [Unreleased]` for any behavior change.


---


## README template

Use the following skeleton when creating a new pattern domain. Replace the placeholder text and update the basic metric view definition, sample question, measure definition, test query, screenshot, and end-to-end YAML link to match the new domain.

````markdown
# <Pattern domain>

## Introduction

<One paragraph, non-technical language: what this pattern domain covers, why it matters, and the kind of business questions it answers.>


## Preparation

1. Ensure that you have created the test dataset using the [tpc-h.sql](/tpc-h.sql) script.

2. Create the basic metric view definition.
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

    fields:
      - name: CustomerName
        display_name: Customer Name
        expr: customer.c_name

      - name: OrderDate
        display_name: Order Date
        expr: o_orderdate

    measures:
      - name: TotalPrice
        display_name: Total Price
        expr: SUM(o_totalprice)
        format:
          type: currency
          currency_code: USD
          decimal_places:
            type: exact
            places: 2
          hide_group_separator: false
          abbreviation: none
    ```

    </details>


## <Pattern name>

**Sample question** - *<Business-user question the pattern answers>*

### Measure definition

```yaml
- name: TotalPrice_T7d
  display_name: Total Price - trailing 7d
  expr: TotalPrice
  window:
    - order: OrderDate
      range: trailing 7 day
      semiadditive: last
  format:
    type: currency
    currency_code: USD
    decimal_places:
      type: exact
      places: 2
    hide_group_separator: false
    abbreviation: none
```

### Test query

```sql
SELECT OrderDate, AGG(TotalPrice), AGG(TotalPrice_T7d)
FROM mv_<PatternName>
WHERE OrderDate BETWEEN '1995-01-01' AND '1995-01-14'
GROUP BY ALL
ORDER BY OrderDate
```

<details>
<summary>Test query output</summary>

<img width="600" src="./images/sample-output.png" alt="Test query output" />

</details>


## End-to-end template

The end-to-end reference implementation can be found in the [<Pattern domain>](./<Pattern%20domain>.yml) YAML file.
````
