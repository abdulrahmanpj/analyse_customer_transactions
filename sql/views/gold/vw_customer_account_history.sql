CREATE OR REPLACE VIEW `${PROJECT_ID}.pjabdulrahman_gold.vw_customer_account_history` AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.phone,
    c.address_line_1,
    c.customer_segment,
    c.kyc_status,
    c.effective_from AS customer_effective_from,
    c.effective_to AS customer_effective_to,
    c.current_record_flag AS customer_current_record_flag,
    a.account_id,
    a.branch_id,
    a.account_type_id,
    a.status AS account_status,
    a.current_balance,
    a.currency,
    a.effective_from AS account_effective_from,
    a.effective_to AS account_effective_to,
    a.current_record_flag AS account_current_record_flag
FROM `${PROJECT_ID}.pjabdulrahman_gold.dim_customer` c
JOIN `${PROJECT_ID}.pjabdulrahman_gold.dim_account` a
    ON c.customer_id = a.customer_id
    AND c.effective_from < COALESCE(a.effective_to, TIMESTAMP '9999-12-31 00:00:00+00')
    AND a.effective_from < COALESCE(c.effective_to, TIMESTAMP '9999-12-31 00:00:00+00');
