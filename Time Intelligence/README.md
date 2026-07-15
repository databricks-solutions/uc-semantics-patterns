# :date: Time Intelligence

## Introduction

Time Intelligence in BI/analytics refers to a set of calculation patterns and functions that analyze data across time periods, enabling comparisons and aggregations relative to dates - such as:

- period-to-date, e.g., year-to-date (YTD), quarter-to-date (QTD), month-to-date (MTD)
- period-over-period growth, e.g., YoY, QoQ, MoM
- rolling/moving averages
- prior-period comparisons
- same-period-last-year metrics

It relies on a dedicated date/calendar dimension table that maps every date to its fiscal and calendar attributes (year, quarter, month, week, day-of-week, holidays), allowing users to slice measures by time hierarchies and compute time-shifted values without rewriting SQL for each period. So business users can consistently answer questions like "how did sales this quarter compare to the same quarter last year?"

In this section, we discuss the implementation of common time intelligence patterns in Unity Catalog semantics.


## Table of Contents

| #  | Folder                                                      | Description                                                                     |
| -- | ----------------------------------------------------------- | ------------------------------------------------------------------------------- |
| 01 | [Period-to-date totals](./Period-to-date%20totals/)         | Cumulative totals from the start of a period (YTD, QTD, MTD)                    |
| 02 | [Period-over-period growth](./Period-over-period%20growth/) | Growth vs. the same prior period (YoY, QoQ, MoM, WoW)                           |
| 03 | [Period-to-date growth](./Period-to-date%20growth/)         | Growth vs. the same point in the prior period (YOYTD, QOQTD, MOMTD, WOWTD)      |
| 04 | [Moving calculations](./Moving%20calculations/)             | Rolling/trailing window totals and averages (7-day, 1-month, 1-quarter, 1-year) |
