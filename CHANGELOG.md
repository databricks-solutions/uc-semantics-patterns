# Changelog

All notable changes to this project are documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [1.1.0] - 2026-08-01
### Added
- **Dynamic ranking** patterns - Basic ranking (`RANK`), Dense ranking (`DENSE_RANK`), Row number (`ROW_NUMBER`), Buckets (`NTILE`), Percentile standing (`PERCENT_RANK`), Cumulative distribution (`CUME_DIST`) — each as Global and Year (`PARTITION BY Year`) variants, with an end-to-end YAML template.
- **Static ranking** - using precomputed values, so ranks stay fixed across regrouping (works with all ranking functions).


## [1.0.0] - 2026-07-15
### Added
- Initial release of the project.
- Curated collection of Unity Catalog semantics patterns.
- Time Intelligence patterns: period-to-date totals (YTD/QTD/MTD), period-over-period growth (YoY/QoQ/MoM/WoW), period-to-date growth (YOYTD/QOQTD/MOMTD/WOWTD), and moving/rolling calculations.
- Semi-additive calculations: opening/closing balances, first/last date values, and growth-in-period.
- End-to-end YAML templates for each pattern and TPC-H / TPC-DS setup scripts.