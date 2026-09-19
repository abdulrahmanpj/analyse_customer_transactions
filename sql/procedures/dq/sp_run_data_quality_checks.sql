CREATE
OR REPLACE PROCEDURE `${PROJECT_ID}.pjabdulrahman_dq.sp_run_data_quality_checks` (p_batch_id STRING, p_layer STRING) 
BEGIN IF p_layer = 'SILVER' THEN 
INSERT `${PROJECT_ID}.pjabdulrahman_dq.quarantine_records`
SELECT
    'CUSTOMERS',
    CAST(customer_id AS STRING),
    batch_id,
    NULL,
    'missing_customer_fields',
    'Email or phone is blank',
    CURRENT_TIMESTAMP()
FROM
    `${PROJECT_ID}.pjabdulrahman_silver.silver_customers`
WHERE
    batch_id = p_batch_id
    AND (
        NULLIF(email, '') IS NULL
        OR NULLIF(phone, '') IS NULL
    );

END IF;

END;