-- Email Marketing Analytics
-- Dataset: data-analytics-mate.DA
-- Description: Builds a unified dataset combining account creation dynamics
--              and email activity metrics segmented by country, send interval,
--              verification and subscription status. Top 10 countries only.
-- Visualization: https://lookerstudio.google.com/reporting/eceb9f52-b293-4633-b4f1-8e98231c212e

WITH account_metrics AS (

  -- Step 1: Account metrics — count created accounts per date, country and segment
  SELECT
    s.date,
    sp.country,
    send_interval,
    is_verified,
    is_unsubscribed,
    COUNT(DISTINCT ac.id) AS account_cnt,
    0                     AS sent_msg,
    0                     AS open_msg,
    0                     AS visit_msg
  FROM data-analytics-mate.DA.account AS ac
  JOIN data-analytics-mate.DA.account_session AS acs 
  ON ac.id = acs.account_id
  JOIN data-analytics-mate.DA.session AS s           
  USING (ga_session_id)
  JOIN data-analytics-mate.DA.session_params AS sp   
  USING (ga_session_id)
  GROUP BY 1,2,3,4,5
),

email_metrics AS (

  -- Step 2: Email metrics — count sent, opened and visited messages per segment
  SELECT
    DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS date,
    sp.country,
    send_interval,
    is_verified,
    is_unsubscribed,
    0                              AS account_cnt,
    COUNT(DISTINCT es.id_message)  AS sent_msg,
    COUNT(DISTINCT eo.id_message)  AS open_msg,
    COUNT(DISTINCT ev.id_message)  AS visit_msg
  FROM `DA.email_sent` AS es
  JOIN data-analytics-mate.DA.account_session AS acs 
  ON es.id_account = acs.account_id
  LEFT JOIN data-analytics-mate.DA.account AS ac     
  ON es.id_account = ac.id
  LEFT JOIN data-analytics-mate.DA.session AS s      
  USING (ga_session_id)
  LEFT JOIN `DA.session_params` AS sp                
  USING (ga_session_id)
  LEFT JOIN `DA.email_open` AS eo                    
  ON es.id_message = eo.id_message
  LEFT JOIN `DA.email_visit` AS ev                   
  ON es.id_message = ev.id_message
  GROUP BY 1,2,3,4,5
),

combined_data AS (

  -- Step 3: Combine account and email metrics into a single dataset via UNION ALL
  SELECT * FROM account_metrics
  UNION ALL
  SELECT * FROM email_metrics
),

total_table AS (

  -- Step 4: Re-aggregate to merge rows with the same dimensions after UNION ALL
  SELECT
    date, country, send_interval, is_verified, is_unsubscribed,
    SUM(account_cnt) AS account_cnt,
    SUM(sent_msg)    AS sent_msg,
    SUM(open_msg)    AS open_msg,
    SUM(visit_msg)   AS visit_msg
  FROM combined_data
  GROUP BY 1,2,3,4,5
),

total_cnt AS (

  -- Step 5: Add country-level totals using window functions
  SELECT *,
    SUM(account_cnt) OVER (PARTITION BY country) AS total_country_account_cnt,
    SUM(sent_msg)    OVER (PARTITION BY country) AS total_country_sent_cnt
  FROM total_table
)

-- Step 6: Rank countries and filter to top 10 by accounts or sent messages
SELECT *,
  DENSE_RANK() OVER (ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt,
  DENSE_RANK() OVER (ORDER BY total_country_sent_cnt    DESC) AS rank_total_country_sent_cnt
FROM total_cnt
QUALIFY
  rank_total_country_account_cnt <= 10
  OR rank_total_country_sent_cnt <= 10
