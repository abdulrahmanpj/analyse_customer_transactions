CREATE TABLE IF NOT EXISTS `${PROJECT_ID}.pjabdulrahman_silver.silver_account_types` (
  account_type_id INT64, type_name STRING, interest_rate NUMERIC,
  min_balance NUMERIC, overdraft_limit NUMERIC, batch_id STRING, processed_at TIMESTAMP
);
