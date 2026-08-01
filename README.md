# Meridian Logistics Group — Fleet Maintenance Cost Leakage & Downtime Risk Analytics

End-to-end fleet analytics platform built on a Medallion (Bronze/Silver/Gold) architecture in SQL Server + Power BI/DAX — uncovering maintenance cost leakage and downtime risk across a 2,200-vehicle logistics fleet.

---

## 1. Project Description

Meridian Logistics Group (MLG) operates a last-mile delivery fleet of ~2,200 vehicles across 6 U.S. regions, serviced by a mix of in-house maintenance depots and third-party vendor garages. Vehicles carry OEM warranties (coverage varies by manufacturer and component) and are fitted with telematics sensors logging fault codes, mileage, and engine diagnostics in real time.

Finance has flagged that maintenance spend is rising year-over-year while fleet size stays flat. Operations is separately seeing a rise in unplanned downtime, causing missed delivery SLAs. This project builds the full data pipeline and analytics layer needed to find out **where the money is leaking, and which vehicles are at risk of breaking down next** — and to make that visible to executives through a Power BI dashboard, not buried in raw tables.

---

## 2. Project Requirements

- A realistic, messy multi-source dataset (not a pre-cleaned tutorial dataset) — simulating extracts from a Fleet Management System, CMMS, telematics platform, HRIS, fuel card processor, OEM warranty portal, and TMS, Vendor Management, Corporate Refrence Data
- A proper dimensional data model (star schema) capable of tracking history where it matters (SCD Type 2 on warranty terms and vehicle assignment/contract history)
- A full SQL-based cleaning pipeline — no manual/Excel cleaning — using reusable functions rather than one-off fixes per table
- A BI layer that answers real executive questions, not just displays charts
- Full traceability: every dashboard visual and KPI must map back to a specific, documented business question

---

## 3. Objectives

1. Simulate realistic source data with intentional data-quality issues (mixed formats, duplicates, orphan keys, currency-as-text, outliers)
2. Build a Bronze → Silver → Gold pipeline in SQL Server, with each layer's role clearly defined and enforced
3. Answer 30 real business questions across 6 planned dashboard pages using advanced SQL (CTEs, window functions, recursive CTEs, non-equi joins)
4. Build a Power BI dashboard with DAX-driven KPIs, drill-through, and row-level security

---

## 4. Specifications

### Data Scale
| | |
|---|---|
| Fleet size | 2,200 vehicles |
| Regions | 6 (U.S.) |
| Tables | 18 (9 dimensions, 2 bridges, 7 facts) |
| Raw rows | 432,127 across all 18 source CSVs |
| Time span | 2023–2026 |

### Source Systems (simulated)
Fleet Management System · CMMS (maintenance/work orders) · Telematics/IoT platform · HRIS · Fuel card system · OEM warranty portal · Transportation Management System (TMS) · Telematics/IoT platform · Vendor Management · Corporate Refrence Data

### Architecture — Medallion (Bronze / Silver / Gold)

| Layer | Object Type | Load | Transformation | Data Model |
|---|---|---|---|---|
| **Bronze** | Table (`stg`) | Batch / Full Load / Truncate & Insert | None | None (as-is) |
| **Silver** | Table (`silver`) | Batch / Full Load / Truncate & Insert | Data cleansing, standardization, normalization, **derived columns** (e.g. `vehicle_age_years`, `cost_per_km`), data enrichment (warranty-key date-range resolution) | None (as-is, still flat) |
| **Gold** | **Views** | No load — computed live from Silver | Data integration (live surrogate keys via `ROW_NUMBER()`), aggregation, business logic (warranty eligibility, risk scoring) | Star schema, flat table, aggregated table |

**SCD Type 2 note:** the raw source CSVs for vehicle-driver assignments, vehicle-vendor contracts, and warranty terms already arrive as complete historical dumps (pre-versioned with `start_date`/`end_date`). Bronze/Silver load these via simple Truncate & Insert — no merge/incremental logic is needed at load time. SCD2 is instead **validated** in Silver (no overlapping/gapped date ranges) and **modeled correctly** in Gold (date-range joins resolve the correct historical version for any given query date).

### Tech Stack
SQL Server · T-SQL (CTEs, window functions, recursive CTEs, non-equi joins, dynamic SQL) · Python (synthetic data generation) · Power BI · DAX

---

## 5. BI: Analytics & Reporting Objectives

The dashboard is built around 6 pages, each with a clear executive objective — full question list in `Documentation/Business/Business_Questions.md`.

| Page | Objective |
|---|---|
| **Executive Summary** | 30-second read on overall cost and downtime trend for a CFO/COO |
| **Finance** | Pinpoint warranty leakage $ by vendor/part; flag vendor billing outliers |
| **Operations** | Downtime hotspots by region/vendor; MTTR benchmarking |
| **Risk** | Vehicles trending toward breakdown, ranked by risk |
| **Forecast** | Projected spend/downtime; what-if scenario modeling |
| **Root Cause Analysis** | Drill-through from any KPI to the vehicle/vendor/part driving it |

**Core KPIs:** Total Maintenance Spend · Warranty Leakage $ and % · Unplanned Downtime Share · Mean Time to Repair (MTTR) · Vendor Cost Variance · On-Time Delivery Rate · Fleet Health Score · Repeat Repair Rate

**Planned DAX techniques:** `CALCULATE`/`FILTER`, time intelligence (`SAMEPERIODLASTYEAR`, `DATEADD`, `TOTALYTD`), `RANKX`/`TOPN` leaderboards, `SWITCH`-based composite scoring, What-If parameters for scenario modeling

**Reporting features planned:** navigation/bookmarks, custom tooltip pages, dynamic titles, conditional formatting, row-level security by region

---

## About Me

**[Anurag Bhardwaj]**
Aspiring Data Analyst | SQL · Power BI · Data Modeling · ETL

This project was built end-to-end as a portfolio piece to demonstrate the full analytics lifecycle — business framing, data modeling, SQL-based ETL, and BI development — rather than just dashboard creation.

📧 [your.email@example.com](mailto:your.email@example.com) · 💼 [LinkedIn](https://linkedin.com/in/yourprofile) · 🖥️ [GitHub](https://github.com/AnnyB1234)

---

## License

This project is licensed under the MIT License — see [`LICENSE`](LICENSE) for details.

> Note: this repository uses a synthetically generated dataset built to simulate a realistic fleet maintenance business scenario. It does not represent any real company's data.

