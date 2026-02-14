# 📊 Marketing Campaign & GA4 Funnel Analysis

An end-to-end marketing analytics case study combining:

- **PostgreSQL campaign performance analysis**
- **GA4 session-level funnel modeling (BigQuery)**
- **Landing page attribution**
- **Behavioral correlation analysis**

The project demonstrates cross-platform data integration, KPI computation, session modeling, and behavioral analytics using production-style SQL.

---

## 🧩 Part 1 — Marketing Campaign Performance (PostgreSQL)

### Tech Stack

- PostgreSQL
- DBeaver
- Window Functions (`LAG`, `ROW_NUMBER`)
- Time-series aggregation
- Cross-platform data merging (`UNION ALL`)

### Data Source

Database: `ads_analysis_goit_course`  
Schema: `public`

Tables:

- `facebook_ads_basic_daily`
- `google_ads_basic_daily`
- `facebook_campaign`
- `facebook_adset`

---

### ✅ Task 1 — Daily Spend Metrics

Calculated daily average, maximum, and minimum spend values.

**Sample Output**

| ad_date | avg_spend | max_spend | min_spend |
|---|---:|---:|---:|
| 2020-11-16 | 2760 | 2760 | 2760 |
| 2020-12-03 | 3214 | 3214 | 3214 |

**Insight:** Daily volatility highlights budget pacing differences across advertising channels.

---

### ✅ Task 2 — Top 5 Days by ROMI

**ROMI formula:** ROMI = 100 × (Total Value − Total Spend) / Total Spend

**Sample Output**

| ad_date | romi |
|---|---:|
| 2022-01-11 | 148.69 |
| 2022-01-07 | 145.66 |

**Insight:** Top-performing days exceeded 145% return, indicating efficient budget allocation.

---

### ✅ Task 3 — Weekly Highest Total Value Campaign

Aggregated by ISO week using `EXTRACT(YEAR)` and `EXTRACT(WEEK)`.

**Sample Output**

| campaign_name | year | iso_week | total_value |
|---|---:|---:|---:|
| Expansion | 2022 | 15 | 2294120 |

**Insight:** Weekly grouping helps identify campaign-level performance peaks.

---

### ✅ Task 4 — Largest Month-over-Month Reach Increase

Used `DATE_TRUNC()` and `LAG()` for MoM growth analysis.

**Sample Output**

| campaign_name | month | monthly_reach | previous_monthly_reach | monthly_reach_diff |
|---|---|---:|---:|---:|
| Hobbies | 2022-04-01 | 5011659 | 745084 | 4266575 |

**Insight:** MoM delta analysis isolates campaigns with significant audience expansion.

---

### ✅ Task 5 — Longest Continuous Adset Exposure

Applied a gaps-and-islands pattern using `ROW_NUMBER()`.

**Sample Output**

| adset_name | streak_length | start_date | end_date |
|---|---:|---|---|
| Narrow | 108 | 2021-05-17 | 2021-09-01 |

**Insight:** Identified the longest uninterrupted exposure streak (108 days).

---

## 📈 Part 2 — GA4 Funnel & Behavioral Analytics (BigQuery)

### Tech Stack

- Google BigQuery
- GA4 Public Dataset
- Nested parameter extraction (`UNNEST`)
- Session-level modeling
- Correlation analysis (`CORR`)

Dataset: `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

---

### ✅ Task 2 — Event-Level Data Preparation (2021)

Prepared a BI-ready event dataset including:

- `event_date`, `user_pseudo_id`, `session_id`, `event_name`
- `country`, `device_category`
- `source`, `medium`, `campaign_name`

Key techniques:

- Timestamp conversion (`TIMESTAMP_MICROS`)
- Nested field extraction (`UNNEST(event_params)`)
- Partition filtering via `_TABLE_SUFFIX`
- Funnel event filtering

---

### ✅ Task 3 — Session-Level Funnel Conversion

Built a session-level funnel grouped by `event_date`, `source`, `medium`, and `campaign`.

**Sample Output**

| event_date | source | sessions | cart % | checkout % | purchase % |
|---|---|---:|---:|---:|---:|
| 2021-01-01 | google | 849 | 2.59 | 1.06 | 0.47 |
| 2021-01-01 | direct | 564 | 4.26 | 1.60 | 0.89 |

**Insight:**
- Direct traffic shows higher purchase conversion than organic (sample dates).
- Conversion drop-off between cart and purchase is visible.
- Accurate attribution ensured via user + session identifiers.

---

### ✅ Task 4 — Landing Page Conversion Comparison (2020)

Extracted landing page from `session_start` and matched with `purchase` via session identifiers.

**Sample Output**

| landing_page_path | total_sessions | purchase_sessions | purchase_cr (%) |
|---|---:|---:|---:|
| Apparel/... | 2 | 2 | 100.0 |
| Campus/... | 2 | 1 | 50.0 |

**Insight:**
- High conversion rates must be evaluated alongside session volume.
- Session-based attribution prevents mismatching landing and purchase URLs.

---

### ✅ Task 5 — Engagement vs Purchase Correlation (2020)

Computed session-level correlations using `CORR()`.

**Sample Output**

| corr_engaged_purchase | corr_time_purchase |
|---|---:|
| 0.112 | 0.326 |

**Insight:**
- Weak positive relationship between engagement presence and purchase (0.11).
- Moderate positive relationship between engagement time and purchase (0.33).
- Engagement duration is a stronger indicator than a binary engagement flag.

---

## 🧠 Skills Demonstrated

- Advanced SQL aggregation and KPI computation (ROMI, MoM growth)
- Window functions and time-series grouping
- Cross-platform marketing data integration
- GA4 nested schema handling and session-level modeling
- Funnel conversion analysis and landing page attribution
- Behavioral feature engineering and correlation analysis in BigQuery

---

## 📂 Repository Structure

Marketing-Campaign-GA4-Funnel-Analysis/  
├── sql-campaign-analysis/  
│   └── campaign_analysis.sql  
├── ga4-funnel-analysis/  
│   ├── task2_event_preparation.sql  
│   ├── task3_funnel_conversion.sql  
│   ├── task4_landing_page_comparison.sql  
│   └── task5_engagement_correlation.sql  
└── README.md  

---

## 📌 Project Summary

This project demonstrates end-to-end marketing analytics capabilities, from campaign KPI evaluation in PostgreSQL to session-level funnel modeling and behavioral analysis in BigQuery. It integrates performance reporting, attribution logic, and behavioral analytics into a unified data workflow.
