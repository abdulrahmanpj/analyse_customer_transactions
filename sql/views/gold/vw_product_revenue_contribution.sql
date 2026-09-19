CREATE OR REPLACE VIEW `${PROJECT_ID}.pjabdulrahman_gold.vw_product_revenue_contribution` AS
WITH account_types AS (
    SELECT *
    FROM `${PROJECT_ID}.pjabdulrahman_silver.silver_account_types`
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY account_type_id ORDER BY processed_at DESC
    ) = 1
), totals AS (
    SELECT
        a.account_type_id,
        t.type_name AS account_type_name,
        COUNT(*) AS transaction_count,
        SUM(f.amount) AS net_transaction_value_gbp,
        SUM(ABS(f.amount)) AS gross_transaction_value_gbp
    FROM `${PROJECT_ID}.pjabdulrahman_gold.fact_transaction` f
    JOIN `${PROJECT_ID}.pjabdulrahman_gold.dim_account` a
        ON a.account_id = f.account_id
        AND a.current_record_flag
    LEFT JOIN account_types t USING(account_type_id)
    WHERE f.currency = 'GBP'
    GROUP BY
        a.account_type_id,
        t.type_name
)
SELECT
    *,
    SAFE_DIVIDE(
        net_transaction_value_gbp,
        SUM(net_transaction_value_gbp) OVER ()
    ) AS net_value_contribution_percentage,
    SAFE_DIVIDE(
        gross_transaction_value_gbp,
        SUM(gross_transaction_value_gbp) OVER ()
    ) AS gross_value_contribution_percentage
FROM totals;
