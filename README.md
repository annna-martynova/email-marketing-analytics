# Email Marketing Analytics

## About
SQL dataset for email marketing analysis combining account creation 
dynamics and email activity metrics (sent, opened, clicked).
Segmented by country, send interval, verification and subscription 
status. Top 10 countries only. Visualized in Looker Studio.

## Tools
SQL, Google BigQuery, Window Functions (SUM, DENSE_RANK),
UNION ALL, QUALIFY, Looker Studio

## Dataset
`data-analytics-mate.DA` — accounts, sessions, email activity

## Metrics Calculated
- Daily created accounts per segment
- Sent, opened and clicked messages
- Total accounts and sent messages by country
- Country rankings by account count and email volume

## Query
[email_marketing_dataset.sql](queries/email_marketing_dataset.sql)

## Dashboard
[View in Looker Studio →](https://lookerstudio.google.com/reporting/eceb9f52-b293-4633-b4f1-8e98231c212e)
