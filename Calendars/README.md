# :calendar: Calendars

## Introduction

Many businesses don't report on the plain Gregorian calendar. Budgets, targets, and results are set on a **custom calendar** whose year, quarters, and periods are shifted or reshaped to match how the business actually runs. Two families are common:

- **Month-based fiscal calendars** keep the ordinary calendar months but start the year in a different month, e.g. July 1. Fiscal quarters and months are renumbered from that start, so fiscal Q1 can be July–September.
- **Week-based retail calendars** replace the months with periods built from **whole weeks**, so every period has the same number of each weekday and year-over-year comparisons line up on the same selling weeks.

Use the fiscal calendar when you report fiscal months and quarters against budgets and targets, and the retail calendar when you need week-aligned comparisons.

Both calendars can be derived **inline** from a single date field in the metric view definition, so every dashboard, Genie space, and SQL consumer inherits the same governed calendar grains.

> [!IMPORTANT]
> **Best practice: materialize the calendar in the gold layer.** A precalculated calendar dimension table, joined to the facts by date, is the recommended approach. It is computed once instead of on every query, it can be reused by every metric view, and it can carry attributes that are hard to derive with a formula, such as holidays, promotional events, or company-specific fiscal exceptions.
>
> Implement the calendar logic inline in the metric view definition, as shown in these patterns, only when a calendar table isn't an option. For example:
> - you don't have permission to create or modify tables in the gold layer
> - the source data is read-only for you, e.g. it is owned by another team or shared with you through Delta Sharing
> - you are prototyping or running a proof of concept, before a data engineering pipeline exists
> - adding and maintaining a calendar table would require a change request or release cycle you can't wait for
> - you want a self-contained metric view definition that is easy to share and deploy

> [!NOTE]
> The retail 4-5-4 calendar is not the only week-based calendar. Other common variants are:
> - **4-4-5** and **5-4-4**: the same 13-week quarters, with the 5-week period in a different position. 4-4-5 is widespread in manufacturing and corporate finance.
> - **13-period (4-4-4)**: thirteen 4-week periods instead of twelve months, so every period has exactly the same length.
> - **52/53-week fiscal years with a different year end**: the year ends on a fixed weekday nearest to, or on the last one of, a chosen month (e.g. the last Saturday of September), instead of near Feb 1.
> - **ISO 8601 week date**: weeks run Monday–Sunday and week 1 is the week that contains the first Thursday of the year. It has no periods or quarters of its own.
> - **Broadcast calendar**: used in media and advertising; weeks run Monday–Sunday and each broadcast month ends on the last Sunday of the Gregorian month, so months have 4 or 5 weeks.


## Table of Contents

| #  | Folder                                  | Description                                                                                                 |
| -- | --------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| 01 | [Fiscal Calendar](./Fiscal%20Calendar/) | Month-based fiscal calendar with a custom start month (e.g. July 1), fiscal quarters and months             |
| 02 | [Retail Calendar](./Retail%20Calendar/) | National Retail Federation (NRF) 4-5-4 standard calendar extending Gregorian calendar for retail purposes   |
