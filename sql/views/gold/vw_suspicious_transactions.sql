CREATE OR REPLACE VIEW `${PROJECT_ID}.pjabdulrahman_gold.vw_suspicious_transactions` AS
SELECT transaction_id, customer_id, account_id, transaction_datetime,
       amount, currency, channel, 'ABS_AMOUNT_OVER_GBP_100000' AS reason
FROM `${PROJECT_ID}.pjabdulrahman_gold.fact_transaction`
WHERE currency = 'GBP' AND ABS(amount) > 100000;
