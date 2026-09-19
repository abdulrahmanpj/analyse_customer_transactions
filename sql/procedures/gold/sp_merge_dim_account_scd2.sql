CREATE OR REPLACE PROCEDURE `${PROJECT_ID}.pjabdulrahman_gold.sp_merge_dim_account_scd2`(
  p_batch_id STRING,
  p_effective_ts TIMESTAMP
)
BEGIN
  CREATE TEMP TABLE src AS
  SELECT * FROM `${PROJECT_ID}.pjabdulrahman_silver.silver_accounts`
  WHERE batch_id = p_batch_id;

  UPDATE `${PROJECT_ID}.pjabdulrahman_gold.dim_account` d
  SET current_record_flag = FALSE, effective_to = p_effective_ts
  WHERE d.current_record_flag
    AND EXISTS (
      SELECT 1 FROM src s
      WHERE s.account_id = d.account_id
        AND (
          s.customer_id IS DISTINCT FROM d.customer_id OR
          s.branch_id IS DISTINCT FROM d.branch_id OR
          s.account_type_id IS DISTINCT FROM d.account_type_id OR
          s.sort_code IS DISTINCT FROM d.sort_code OR
          s.open_date IS DISTINCT FROM d.open_date OR
          s.close_date IS DISTINCT FROM d.close_date OR
          s.status IS DISTINCT FROM d.status OR
          s.current_balance IS DISTINCT FROM d.current_balance OR
          s.currency IS DISTINCT FROM d.currency
        )
    );

  INSERT INTO `${PROJECT_ID}.pjabdulrahman_gold.dim_account`
  SELECT GENERATE_UUID(), s.account_id, s.customer_id, s.branch_id, s.account_type_id,
         s.sort_code, s.open_date, s.close_date, s.status, s.current_balance, s.currency,
         p_effective_ts, NULL, TRUE, p_batch_id
  FROM src s
  LEFT JOIN `${PROJECT_ID}.pjabdulrahman_gold.dim_account` d
    ON d.account_id = s.account_id AND d.current_record_flag
  WHERE d.account_id IS NULL;
END;
