CREATE OR REPLACE PROCEDURE `${PROJECT_ID}.pjabdulrahman_gold.sp_merge_dim_customer_scd2`(
  p_batch_id STRING,
  p_effective_ts TIMESTAMP
)
BEGIN
  CREATE TEMP TABLE src AS
  SELECT * FROM `${PROJECT_ID}.pjabdulrahman_silver.silver_customers`
  WHERE batch_id = p_batch_id;

  UPDATE `${PROJECT_ID}.pjabdulrahman_gold.dim_customer` d
  SET current_record_flag = FALSE, effective_to = p_effective_ts
  WHERE d.current_record_flag
    AND EXISTS (
      SELECT 1 FROM src s
      WHERE s.customer_id = d.customer_id
        AND (
          s.first_name IS DISTINCT FROM d.first_name OR
          s.last_name IS DISTINCT FROM d.last_name OR
          s.email IS DISTINCT FROM d.email OR
          s.phone IS DISTINCT FROM d.phone OR
          s.address_line_1 IS DISTINCT FROM d.address_line_1 OR
          s.customer_segment IS DISTINCT FROM d.customer_segment OR
          s.kyc_status IS DISTINCT FROM d.kyc_status
        )
    );

  INSERT INTO `${PROJECT_ID}.pjabdulrahman_gold.dim_customer`
  SELECT GENERATE_UUID(), s.customer_id, s.first_name, s.last_name, s.email, s.phone,
         s.address_line_1, s.customer_segment, s.kyc_status,
         p_effective_ts, NULL, TRUE, p_batch_id
  FROM src s
  LEFT JOIN `${PROJECT_ID}.pjabdulrahman_gold.dim_customer` d
    ON d.customer_id = s.customer_id AND d.current_record_flag
  WHERE d.customer_id IS NULL;
END;
