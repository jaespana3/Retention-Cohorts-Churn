WITH cohort_data AS (
  SELECT
    user_pseudo_id,
    DATE(subscription_start) AS subscription_start_date,
    DATE_TRUNC(subscription_start, WEEK(SUNDAY)) AS cohort_week,
    IFNULL(subscription_end, '9999-12-31') AS subscription_end
  FROM
    `turing_data_analytics.subscriptions`
  WHERE
    subscription_start <= '2021-02-07'
),
week_retention AS (
  SELECT
    cohort_week,
    COUNT(DISTINCT user_pseudo_id) AS cohort_size,
    COUNT(DISTINCT CASE WHEN subscription_end > DATE_ADD(subscription_start_date, INTERVAL 0 WEEK) THEN user_pseudo_id END) AS week_0,
    COUNT(DISTINCT CASE WHEN subscription_end > DATE_ADD(subscription_start_date, INTERVAL 1 WEEK) THEN user_pseudo_id END) AS week_1,
    COUNT(DISTINCT CASE WHEN subscription_end > DATE_ADD(subscription_start_date, INTERVAL 2 WEEK) THEN user_pseudo_id END) AS week_2,
    COUNT(DISTINCT CASE WHEN subscription_end > DATE_ADD(subscription_start_date, INTERVAL 3 WEEK) THEN user_pseudo_id END) AS week_3,
    COUNT(DISTINCT CASE WHEN subscription_end > DATE_ADD(subscription_start_date, INTERVAL 4 WEEK) THEN user_pseudo_id END) AS week_4,
    COUNT(DISTINCT CASE WHEN subscription_end > DATE_ADD(subscription_start_date, INTERVAL 5 WEEK) THEN user_pseudo_id END) AS week_5,
    COUNT(DISTINCT CASE WHEN subscription_end > DATE_ADD(subscription_start_date, INTERVAL 6 WEEK) THEN user_pseudo_id END) AS week_6
  FROM
    cohort_data
  GROUP BY
    cohort_week
),

retention_rate AS (
  SELECT
    cohort_week,
    cohort_size,
    SAFE_DIVIDE(week_0, cohort_size) AS retention_week_0,
    SAFE_DIVIDE(week_1, cohort_size) AS retention_week_1,
    SAFE_DIVIDE(week_2, cohort_size) AS retention_week_2,
    SAFE_DIVIDE(week_3, cohort_size) AS retention_week_3,
    SAFE_DIVIDE(week_4, cohort_size) AS retention_week_4,
    SAFE_DIVIDE(week_5, cohort_size) AS retention_week_5,
    SAFE_DIVIDE(week_6, cohort_size) AS retention_week_6
  FROM
    week_retention
)
SELECT
  cohort_week,
  cohort_size,
  retention_week_0 * 100 AS retention_week_0_pct,
  retention_week_1 * 100 AS retention_week_1_pct,
  retention_week_2 * 100 AS retention_week_2_pct,
  retention_week_3 * 100 AS retention_week_3_pct,
  retention_week_4 * 100 AS retention_week_4_pct,
  retention_week_5 * 100 AS retention_week_5_pct,
  retention_week_6 * 100 AS retention_week_6_pct
FROM
  retention_rate
ORDER BY
  cohort_week;
