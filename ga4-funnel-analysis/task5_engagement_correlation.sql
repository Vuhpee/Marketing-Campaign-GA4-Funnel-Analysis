/*
Project: Marketing Campaign & GA4 Funnel Analysis
Author: Alican Gundogdu
Tool: BigQuery (GA4 Public Dataset)
Task: Task 5 — Engagement vs Purchase Correlation (2020)

Description:
Performs session-level feature engineering and correlation analysis:
- session_engaged flag (0/1)
- total engagement_time_msec per session
- purchase flag based on purchase event presence
- correlations computed via CORR() function

Dataset:
bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*
*/

WITH aggregated AS (
  SELECT
    event_name,
    (
      SELECT CAST(value.string_value AS INT64)
      FROM UNNEST(event_params)
      WHERE key = 'session_engaged'
    ) AS session_engaged,
    (
      SELECT value.int_value
      FROM UNNEST(event_params)
      WHERE key = 'engagement_time_msec'
    ) AS engagement_time_msec,
    CONCAT(
      user_pseudo_id, '-',
      CAST((
        SELECT value.int_value
        FROM UNNEST(event_params)
        WHERE key = 'ga_session_id'
      ) AS STRING)
    ) AS user_session_id
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20200101' AND '20201231'
),
session_engagement_time AS (
  SELECT
    user_session_id,
    SUM(IFNULL(engagement_time_msec, 0)) AS total_engagement_time_msec
  FROM aggregated
  GROUP BY user_session_id
),
session_engagement_flag AS (
  SELECT
    user_session_id,
    CASE WHEN MAX(session_engaged) = 1 THEN 1 ELSE 0 END AS engagement_flag
  FROM aggregated
  GROUP BY user_session_id
),
purchase_sessions AS (
  SELECT DISTINCT
    user_session_id,
    1 AS purchase_flag
  FROM aggregated
  WHERE event_name = 'purchase'
),
final AS (
  SELECT
    t.user_session_id,
    t.total_engagement_time_msec,
    COALESCE(p.purchase_flag, 0) AS purchase_flag,
    f.engagement_flag
  FROM session_engagement_time t
  LEFT JOIN purchase_sessions p
    ON t.user_session_id = p.user_session_id
  LEFT JOIN session_engagement_flag f
    ON t.user_session_id = f.user_session_id
)
SELECT
  CORR(engagement_flag, purchase_flag) AS corr_engaged_purchase,
  CORR(total_engagement_time_msec, purchase_flag) AS corr_time_purchase
FROM final;

