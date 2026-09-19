CREATE OR REPLACE PROCEDURE `${PROJECT_ID}.pjabdulrahman_gold.sp_build_gold`(
    p_batch_id STRING
)
BEGIN
    MERGE `${PROJECT_ID}.pjabdulrahman_gold.fact_transaction` t
    USING (
        WITH latest_accounts AS (
            SELECT
                account_id,
                customer_id
            FROM `${PROJECT_ID}.pjabdulrahman_silver.silver_accounts`
            QUALIFY ROW_NUMBER() OVER (
                PARTITION BY account_id ORDER BY processed_at DESC
            ) = 1
        )
        SELECT
            x.transaction_id,
            x.account_id,
            a.customer_id,
            x.transaction_datetime,
            x.amount,
            x.currency,
            x.channel,
            x.batch_id
        FROM `${PROJECT_ID}.pjabdulrahman_silver.silver_transactions` x
        JOIN latest_accounts a USING(account_id)
        WHERE x.batch_id = p_batch_id
    ) s
        ON t.transaction_id = s.transaction_id
    WHEN NOT MATCHED THEN
        INSERT ROW;
END;
