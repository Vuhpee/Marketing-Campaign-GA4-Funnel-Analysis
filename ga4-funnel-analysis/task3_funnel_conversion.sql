/*
Project: Marketing Campaign & GA4 Funnel Analysis
Author: Alican Gundogdu
Tool: BigQuery (GA4 Public Dataset)
Task: Task 3 — Session-Level Funnel Conversion (2021)

Description:
Builds a session-level funnel conversion table grouped by:
- event_date, source, medium, campaign

Key steps:
- Extract ga_session_id from nested event_params
- Create a unique session key: user_pseudo_id + ga_session_id
- Count distinct sessions for each funnel step
- Compute conversion rates (% of sessions)

Dataset:
bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*
*/

WITH aggregated AS (
  SELECT
    event_name,
    user_pseudo_id,
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS event_date,
    traffic_source.source AS source,
    traffic_source.medium AS medium,
    traffic_source.name AS campaign,
    CONCAT(
      user_pseudo_id, '-',
      CAST((
        SELECT value.int_value
        FROM UNNEST(event_params)
        WHERE key = 'ga_session_id'
      ) AS STRING)
    ) AS user_session_id
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20211231'
    AND event_name IN ('session_start', 'add_to_cart', 'begin_checkout', 'purchase')
),
counts AS (
  SELECT
    event_date,
    source,
    ANY_VALUE(medium) AS medium,
    ANY_VALUE(campaign) AS campaign,
    COUNT(DISTINCT IF(event_name = 'session_start', user_session_id, NULL)) AS user_sessions_count,
    COUNT(DISTINCT IF(event_name = 'add_to_cart', user_session_id, NULL)) AS add_to_cart_sessions,
    COUNT(DISTINCT IF(event_name = 'begin_checkout', user_session_id, NULL)) AS begin_checkout_sessions,
    COUNT(DISTINCT IF(event_name = 'purchase', user_session_id, NULL)) AS purchase_sessions
  FROM aggregated
  GROUP BY event_date, source
)
SELECT
  event_date,
  source,
  medium,
  campaign,
  user_sessions_count,
  ROUND(100.0 * add_to_cart_sessions / user_sessions_count, 2) AS visit_to_cart,
  ROUND(100.0 * begin_checkout_sessions / user_sessions_count, 2) AS visit_to_checkout,
  ROUND(100.0 * purchase_sessions / user_sessions_count, 2) AS visit_to_purchase
FROM counts;

