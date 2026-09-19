CREATE
OR REPLACE VIEW `${PROJECT_ID}.pjabdulrahman_gold.vw_transaction_kpis` AS
SELECT
    DATE (transaction_datetime) transaction_date,
    channel,
    COUNT(*) transaction_count,
    SUM(ABS(amount)) gross_value_gbp
FROM
    `${PROJECT_ID}.pjabdulrahman_gold.fact_transaction`
WHERE
    currency = 'GBP'
GROUP BY
    transaction_date,
    channel;