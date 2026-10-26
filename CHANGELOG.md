# Changelog

All notable changes to this project are documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.1] - 2026-10-23
### Changed
- **Dynamic segmentation** patterns - Reworked the population counts to show how per-year counts combine across a multi-year selection. `Count_ranges` is now a plain distinct count; `Count_ranges_growth` and `Count_highest_ranges` use `partition: {include: [Year], outer_aggregate: avg}` to give the average number of members per tier per year. The README explains which business question each aggregation answers (sum across years vs. average per year), adds a second lifetime-status test query with its output, and adds a tip on rounding fractional averages for display (`Count_highest_ranges` now shows whole numbers). README snippets are aligned with `Dynamic_segmentation.yml`.

## [1.4.0] - 2026-09-21
### Added
- **Dynamic segmentation** patterns - Query-time customer segmentation into tiers by yearly sales (LOW/MEDIUM/HIGH), by year-over-year growth trajectory (DROP/STABLE/GROW/UNICORN), and by all-time highest (best-ever) tier — using measure-level `partition` (INCLUDE level-of-detail) counts.

## [1.3.0] - 2026-08-31
### Added
- **Static segmentation** patterns - Static price-band segmentation (global bands, per-category bands) and bands sourced from an external configuration table

## [1.2.0] - 2026-08-07
### Added
- **Currency conversion** pattern: convert amounts into a user-selected reporting currency using query-time parameters — single source / multiple targets, multiple sources / multiple targets, and multiple exchange-rate types (AVG/EOP). 


## [1.1.0] - 2026-08-01
### Added
- **Dynamic ranking** patterns - Basic ranking (`RANK`), Dense ranking (`DENSE_RANK`), Row number (`ROW_NUMBER`), Buckets (`NTILE`), Percentile standing (`PERCENT_RANK`), Cumulative distribution (`CUME_DIST`) — each as Global and Year (`PARTITION BY Year`) variants, with an end-to-end YAML template.
- **Static ranking** - using precomputed values, so ranks stay fixed across regrouping (works with all ranking functions).


## [1.0.0] - 2026-07-15
### Added
- Initial release of the project.
- Curated collection of Unity Catalog semantics patterns.
- **Time Intelligence patterns**: period-to-date totals (YTD/QTD/MTD), period-over-period growth (YoY/QoQ/MoM/WoW), period-to-date growth (YOYTD/QOQTD/MOMTD/WOWTD), and moving/rolling calculations.
- **Semi-additive calculations**: opening/closing balances, first/last date values, and growth-in-period.
- End-to-end YAML templates for each pattern and TPC-H / TPC-DS setup scripts.