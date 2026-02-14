# 📊 Marketing Campaign & GA4 Funnel Analysis

This project presents an end-to-end marketing analytics case study combining:

- SQL-based campaign performance analysis (PostgreSQL)
- GA4 funnel modeling and behavioral analytics (BigQuery)

The objective is to analyze advertising performance, construct session-level conversion funnels, evaluate landing page effectiveness, and measure the relationship between user engagement and purchase behavior.

---

# Part 1 — Marketing Campaign Performance (SQL / PostgreSQL)

## Tech Stack
- SQL (PostgreSQL)
- DBeaver
- Window Functions (LAG, ROW_NUMBER)
- Time-Series Aggregation
- Cross-Platform Data Merging (UNION ALL)

## Data Source
Database: `ads_analysis_goit_course`  
Schema: `public`

Tables:
- facebook_ads_basic_daily
- google_ads_basic_daily
- facebook_campaign
- facebook_adset

---

## Task 1 — Daily Spend Metrics

Calculated daily average, maximum, and minimum spend values.

### Sample Output

| ad_date   | avg_spend | max_spend | min_spend |
|------------|-----------|-----------|-----------|
| 2020-11-16 | 2,760     | 2,760     | 2,760     |
| 2020-12-03 | 3,214     | 3,214     | 3,214     |

### Insight
Daily spend volatility reveals pacing and budget allocation differences across campaigns.

---

## Task 2 — Top 5 Days by ROMI

ROMI Formula:
ROMI = 100 × (Total Value − Total Spend) / Total Spend

### Sample Output

| ad_date   | romi   |
|------------|--------|
| 2022-01-11 | 148.69 |
| 2022-01-07 | 145.66 |

### Insight
Top-performing days exceeded 145% return, indicating highly efficient budget utilization.

---

## Task 3 — Weekly Highest Total Value Campaign

### Sample Output

| campaign_name | year | iso_week | total_value |
|---------------|------|----------|-------------|
| Expansion     | 2022 | 15       | 2,294,120   |

### Insight
Weekly aggregation identified peak campaign performance using ISO week grouping.

---

## Task 4 — Largest Monthly Reach Increase

### Sample Output

| campaign_name | month       | monthly_reach | previous_monthly_reach | monthly_reach_diff |
|---------------|------------|---------------|-------------------------|--------------------|
| Hobbies       | 2022-04-01 | 5,011,659     | 745,084                 | 4,266,575          |

### Insight
Month-over-month growth analysis via LAG() identified campaigns with significant audience expansion.

---

## Task 5 — Longest Continuous Adset Exposure

### Sample Output

| adset_name | streak_length | start_date  | end_date    |
|------------|--------------|------------|------------|
| Narrow     | 108          | 2021-05-17 | 2021-09-01 |

### Insight
Using a gaps-and-islands pattern, the longest uninterrupted exposure period was calculated at 108 days.

---

# Part 2 — GA4 Funnel & Behavioral Analysis (BigQuery)

## Tech Stack
- Google BigQuery
- GA4 Public Dataset
- Nested Parameter Extraction (UNNEST)
- Session-Level Modeling
- Correlation Analysis (CORR)

Dataset:
`bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

---

## Task 2 — Event-Level Data Preparation (2021)

Prepared a BI-ready dataset including:

- event_date
- user_pseudo_id
- session_id
- event_name
- country
- device_category
- source
- medium
- campaign_name

Key Techniques:
- Converted microsecond timestamps
- Extracted ga_session_id via UNNEST
- Filtered funnel events
- Used partition filtering via _TABLE_SUFFIX

---

## Task 3 — Session-Level Funnel Conversion

Constructed a session-level funnel grouped by:

- event_date
- source
- medium
- campaign

Conversion Metrics:
- visit_to_cart (%)
- visit_to_checkout (%)
- visit_to_purchase (%)

### Sample Output

| event_date | source  | sessions | cart % | checkout % | purchase % |
|------------|----------|----------|--------|------------|------------|
| 2021-01-01 | google   | 849      | 2.59   | 1.06       | 0.47       |
| 2021-01-01 | direct   | 564      | 4.26   | 1.60       | 0.89       |

### Insight
Direct traffic demonstrated higher purchase conversion compared to organic search during sampled dates.

---

## Task 4 — Landing Page Conversion Comparison (2020)

Compared landing pages based on:

- Total sessions
- Purchase sessions
- Purchase conversion rate

### Sample Output

| landing_page_path | total_sessions | purchase_sessions | purchase_cr (%) |
|-------------------|---------------|------------------|----------------|
| Apparel/...       | 2             | 2                | 100.0          |
| Campus/...        | 2             | 1                | 50.0           |

### Insight
Landing page attribution required matching session_start and purchase events via user + session identifiers. High CR pages must be evaluated with volume context.

---

## Task 5 — Engagement vs Purchase Correlation (2020)

Computed session-level correlations:

| corr_engaged_purchase | corr_time_purchase |
|------------------------|-------------------|
| 0.112                  | 0.326             |

### Insight
- Weak positive correlation between engagement presence and purchase (0.11)
- Moderate positive correlation between engagement duration and purchase (0.33)
- Engagement time appears to be a stronger indicator of purchase likelihood than binary engagement status

---

# Skills Demonstrated

- Advanced SQL aggregation and window functions
- Cross-platform marketing data integration
- GA4 nested schema handling
- Session-level modeling
- Funnel conversion analysis
- Landing page attribution
- Behavioral feature engineering
- Correlation analysis in BigQuery
- Marketing performance KPI tracking

---

# Project Summary

This project demonstrates end-to-end marketing analytics capabilities, from campaign performance measurement in PostgreSQL to session-level funnel modeling and behavioral correlation analysis in BigQuery.

It integrates performance reporting, attribution modeling, and behavioral analytics into a unified marketing data workflow.
