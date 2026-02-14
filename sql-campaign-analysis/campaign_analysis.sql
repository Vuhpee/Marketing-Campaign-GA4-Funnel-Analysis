/*
Project: Marketing Campaign & GA4 Funnel Analysis
Author: Alican Gundogdu
Tool: PostgreSQL (executed via DBeaver)
Scope: Marketing Campaign Performance (Google + Facebook)

Description:
This SQL script analyzes multi-channel advertising performance by combining Google and Facebook daily ads data.
It calculates key KPIs and trend metrics including:
- Daily spend statistics (AVG / MAX / MIN)
- Top-performing days by ROMI (combined platforms)
- Weekly highest total value campaign
- Largest month-over-month reach increase (using LAG)
- Longest continuous adset exposure streak (gaps-and-islands with ROW_NUMBER)

Data Source:
Database: ads_analysis_goit_course (schema: public)
Tables: facebook_ads_basic_daily, google_ads_basic_daily, facebook_campaign, facebook_adset

Notes:
- Cross-platform integration is handled via UNION ALL where applicable.
- Window functions used: LAG(), ROW_NUMBER().
*/

/* ============================================================
   TASK 1 — Daily Spend Metrics (Google & Facebook)
   ============================================================ */

-- Facebook
SELECT
    ad_date,
    AVG(spend)::DECIMAL(10,2) AS avg_spend,
    MAX(spend) AS max_spend,
    MIN(spend) AS min_spend
FROM facebook_ads_basic_daily
GROUP BY ad_date
ORDER BY ad_date ASC;

-- Google
SELECT
    ad_date,
    AVG(spend)::DECIMAL(10,2) AS avg_spend,
    MAX(spend) AS max_spend,
    MIN(spend) AS min_spend
FROM google_ads_basic_daily
GROUP BY ad_date
ORDER BY ad_date ASC;


/* ============================================================
   TASK 2 — Top 5 Days by Total ROMI (Combined Platforms)
   ============================================================ */

WITH merged AS (
    SELECT ad_date, spend, value
    FROM facebook_ads_basic_daily
    UNION ALL
    SELECT ad_date, spend, value
    FROM google_ads_basic_daily
)
SELECT 
    ad_date,
    CASE
        WHEN SUM(COALESCE(spend,0)) = 0 THEN -9999
        ELSE ROUND(100.0 * (SUM(value) - SUM(spend)) / SUM(spend), 2)
    END AS romi
FROM merged
GROUP BY ad_date
ORDER BY romi DESC
LIMIT 5;


/* ============================================================
   TASK 3 — Weekly Highest Total Value Campaign
   ============================================================ */

WITH merged AS (
    SELECT
        EXTRACT(YEAR FROM ad_date) AS year_date,
        EXTRACT(WEEK FROM ad_date) AS iso_week,
        campaign_name,
        value
    FROM facebook_ads_basic_daily fabd
    LEFT JOIN facebook_campaign fc 
        ON fabd.campaign_id = fc.campaign_id

    UNION ALL

    SELECT
        EXTRACT(YEAR FROM ad_date),
        EXTRACT(WEEK FROM ad_date),
        campaign_name,
        value
    FROM google_ads_basic_daily
)
SELECT 
    campaign_name,
    year_date,
    iso_week,
    SUM(value) AS total_value
FROM merged
GROUP BY year_date, iso_week, campaign_name
HAVING SUM(value) IS NOT NULL
ORDER BY total_value DESC
LIMIT 1;


/* ============================================================
   TASK 4 — Largest Month-over-Month Reach Increase
   ============================================================ */

WITH merged AS (
    SELECT campaign_name, reach, ad_date
    FROM facebook_ads_basic_daily fabd
    LEFT JOIN facebook_campaign fc 
        ON fabd.campaign_id = fc.campaign_id
    UNION ALL
    SELECT campaign_name, reach, ad_date
    FROM google_ads_basic_daily
),
monthly AS (
    SELECT 
        campaign_name,
        DATE_TRUNC('month', ad_date) AS month,
        SUM(reach) AS monthly_reach,
        LAG(SUM(reach)) OVER (
            PARTITION BY campaign_name
            ORDER BY DATE_TRUNC('month', ad_date)
        ) AS previous_monthly_reach
    FROM merged
    GROUP BY campaign_name, month
)
SELECT
    campaign_name,
    month,
    monthly_reach,
    previous_monthly_reach,
    (monthly_reach - previous_monthly_reach) AS monthly_reach_diff
FROM monthly
WHERE previous_monthly_reach IS NOT NULL
ORDER BY monthly_reach_diff DESC
LIMIT 1;


/* ============================================================
   TASK 5 — Longest Continuous Adset Exposure
   ============================================================ */

WITH merged AS (
    SELECT adset_name, ad_date
    FROM facebook_ads_basic_daily fabd
    LEFT JOIN facebook_adset fa 
        ON fabd.adset_id = fa.adset_id
    WHERE impressions > 0

    UNION ALL

    SELECT adset_name, ad_date
    FROM google_ads_basic_daily
    WHERE impressions > 0
),
distinct_days AS (
    SELECT DISTINCT adset_name, ad_date
    FROM merged
),
grp AS (
    SELECT
        adset_name,
        ad_date,
        ad_date - (
            ROW_NUMBER() OVER (
                PARTITION BY adset_name
                ORDER BY ad_date
            )
        )::INT AS grp_key
    FROM distinct_days
),
streaks AS (
    SELECT
        adset_name,
        COUNT(*) AS streak_length,
        MIN(ad_date) AS start_date,
        MAX(ad_date) AS end_date
    FROM grp
    GROUP BY adset_name, grp_key
)
SELECT *
FROM streaks
ORDER BY streak_length DESC
LIMIT 1;

