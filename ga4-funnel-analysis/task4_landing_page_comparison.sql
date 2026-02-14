/*
Project: Marketing Campaign & GA4 Funnel Analysis
Author: Alican Gundogdu
Tool: BigQuery (GA4 Public Dataset)
Task: Task 4 — Landing Page Conversion Comparison (2020)

Description:
Compares landing pages using session-level attribution:
- Extract landing page from session_start (page_location)
- Identify purchase sessions via purchase event
- Match session_start and purchase by unique user_session_id
- Calculate purchase conversion rate by landing_page_path

Dataset:
bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*
*/

WITH aggregated AS (
  SELECT
    event_name,
    (
      SELECT value.string_value
      FROM UNNEST(event_params)
      WHERE key = 'page_location'
    ) AS page_location,
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
    AND event_name IN ('session_start', 'purchase')
),
landing_pages AS (
  SELECT DISTINCT
    user_session_id,
    REGEXP_EXTRACT(page_location, r'com/([^?#]*)') AS landing_page_path
  FROM aggregated
  WHERE event_name = 'session_start'
),
purchasing_sessions AS (
  SELECT DISTINCT
    user_session_id
  FROM aggregated
  WHERE event_name = 'purchase'
)
SELECT
  lp.landing_page_path,
  COUNT(lp.user_session_id) AS total_sessions,
  COUNT(ps.user_session_id) AS purchase_sessions,
  ROUND(100.0 * COUNT(ps.user_session_id) / COUNT(lp.user_session_id), 2) AS purchase_cr
FROM landing_pages lp
LEFT JOIN purchasing_sessions ps
  ON ps.user_session_id = lp.user_session_id
WHERE lp.landing_page_path IS NOT NULL
  AND lp.landing_page_path <> ''
GROUP BY lp.landing_page_path
ORDER BY purchase_cr DESC;

