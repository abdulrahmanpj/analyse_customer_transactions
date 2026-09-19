CREATE OR REPLACE VIEW `${PROJECT_ID}.pjabdulrahman_gold.vw_card_product_adoption` AS
WITH cards AS (
    SELECT *
    FROM `${PROJECT_ID}.pjabdulrahman_silver.silver_cards`
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY card_id ORDER BY processed_at DESC
    ) = 1
)
SELECT
    cu.customer_id,
    cu.first_name,
    cu.last_name,
    COUNT(DISTINCT a.account_id) AS account_count,
    COUNT(DISTINCT IF(c.status = 'Active', c.card_id, NULL)) AS active_card_count,
    ARRAY_AGG(
        DISTINCT IF(c.status = 'Active', c.card_type, NULL) IGNORE NULLS
    ) AS active_card_types,
    IF(
        COUNT(DISTINCT IF(c.status = 'Active', c.card_id, NULL)) = 0,
        'CROSS_SELL_CANDIDATE_NO_ACTIVE_CARD',
        'HAS_ACTIVE_CARD'
    ) AS adoption_status
FROM `${PROJECT_ID}.pjabdulrahman_gold.dim_customer` cu
LEFT JOIN `${PROJECT_ID}.pjabdulrahman_gold.dim_account` a
    ON cu.customer_id = a.customer_id
    AND a.current_record_flag
LEFT JOIN cards c USING(account_id)
WHERE cu.current_record_flag
GROUP BY
    cu.customer_id,
    cu.first_name,
    cu.last_name;
