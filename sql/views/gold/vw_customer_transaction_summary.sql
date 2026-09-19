CREATE
OR REPLACE VIEW `${PROJECT_ID}.pjabdulrahman_gold.vw_customer_transaction_summary` AS
SELECT
    customer_id,
    COUNT(*) transaction_count,
    SUM(ABS(amount)) gross_value_gbp,
    SUM(amount) net_value_gbp
FROM
    `${PROJECT_ID}.pjabdulrahman_gold.fact_transaction`
WHERE
    currency = 'GBP'
GROUP BY
    customer_id;