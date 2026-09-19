CREATE OR REPLACE VIEW `${PROJECT_ID}.pjabdulrahman_gold.vw_top_5_customers_by_transaction_value` AS
WITH top_customers AS (
    SELECT
        customer_id,
        COUNT(*) AS transaction_count,
        SUM(ABS(amount)) AS gross_transaction_value_gbp,
        SUM(amount) AS net_transaction_value_gbp
    FROM `${PROJECT_ID}.pjabdulrahman_gold.fact_transaction`
    WHERE currency = 'GBP'
    GROUP BY customer_id
    ORDER BY gross_transaction_value_gbp DESC
    LIMIT 5
)
SELECT
    t.customer_id,
    c.first_name,
    c.last_name,
    t.transaction_count,
    t.gross_transaction_value_gbp,
    t.net_transaction_value_gbp
FROM top_customers t
LEFT JOIN `${PROJECT_ID}.pjabdulrahman_gold.dim_customer` c
    ON t.customer_id = c.customer_id
    AND c.current_record_flag
ORDER BY t.gross_transaction_value_gbp DESC;
