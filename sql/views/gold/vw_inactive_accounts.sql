CREATE OR REPLACE VIEW `${PROJECT_ID}.pjabdulrahman_gold.vw_inactive_accounts` AS
SELECT
    a.account_id,
    a.customer_id,
    a.status,
    a.current_balance,
    MAX(DATE(f.transaction_datetime)) AS last_transaction_date,
    CURRENT_DATE() AS processing_date,
    DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH) AS inactivity_cutoff_date
FROM `${PROJECT_ID}.pjabdulrahman_gold.dim_account` a
LEFT JOIN `${PROJECT_ID}.pjabdulrahman_gold.fact_transaction` f USING(account_id)
WHERE a.current_record_flag
GROUP BY
    a.account_id,
    a.customer_id,
    a.status,
    a.current_balance
HAVING
    last_transaction_date IS NULL
    OR last_transaction_date < DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH);
