# :hammer_and_wrench: Unity Catalog semantics patterns

## Introduction

[Unity Catalog semantics](https://docs.databricks.com/aws/en/business-semantics/) is a centralized platform for defining and managing business metrics and KPIs once in [Unity Catalog](https://docs.databricks.com/aws/en/data-governance/unity-catalog/), so that every downstream tool (Databricks SQL, AI/BI dashboards, Genie, and BI clients) shares a single, governed source of truth. But translating common analytical calculations into a Unity Catalog semantics' declarative YAML isn't always obvious.

This repository is a curated collection of ready-to-use code patterns for solving those recurring modeling challenges in [Unity Catalog semantics](https://docs.databricks.com/aws/en/business-semantics/). Each pattern captures a real analytical scenario — the kind of question a business user actually asks — and shows how to answer it correctly with a reference implementation.

Every pattern follows the same structure so you can copy, adapt, and verify quickly:

- **Scenario & sample question** — the business problem, in plain language
- **Measure definition** — the YAML you add to your metric view
- **Test query & output** — a runnable SQL query and its expected result, built on standard TPC-H / TPC-DS sample dataset so you can reproduce it in any workspace
- **End-to-end template** — a complete, working metric view definition for the whole domain

Whether you're building a governed semantic layer from scratch or extending an existing one, these patterns give you tested, production-ready building blocks.


## :clipboard: Table of Contents

| #  | Folder                                                        | Description                                                                                                                                     |
| -- | ------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| 01 | [Time Intelligence](./Time%20Intelligence/)                   | Period-over-period growth (YoY, QoQ, MoM, WoW), period-to-date totals (YTD, QTD, MTD), period-to-date growth, and moving/rolling calculations   |
| 02 | [Semi-additive calculations](./Semi-additive%20calculations/) | Opening and closing balances, first/last date values, and growth-in-period for non-additive measures like inventory and account balances       |
| 03 | [Ranking](./Ranking/)                                         | Dynamic and static ranking of entities by a measure, including global and year-partitioned variants |
| 04 | [Currency conversion](./Currency%20conversion/)               | Convert amounts into a user-selected reporting currency via query-time parameters, using historical FX rates         |
| 05 | [Hierarchies](./Hierarchies/)                                 | Parent-child rollups (ancestor subtotals) and share-of-parent (% of region/country/total) for fixed-depth hierarchies, plus a recursive-CTE flattener for arbitrary-depth self-referential trees |


## :question: How to get help

Databricks support doesn't cover this content. For questions or bugs, please open a GitHub issue and the team will help on a best-effort basis.


## License

&copy; 2025 Databricks, Inc. All rights reserved. The source code in this repository is provided subject to the [Databricks License](https://databricks.com/db-license-source). All included or referenced third-party libraries are subject to the licenses set forth below.



