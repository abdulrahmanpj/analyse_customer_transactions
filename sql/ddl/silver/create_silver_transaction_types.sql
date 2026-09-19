CREATE TABLE IF NOT EXISTS `${PROJECT_ID}.pjabdulrahman_silver.silver_transaction_types` (
  transaction_type_id INT64, type_name STRING, category STRING,
  batch_id STRING, processed_at TIMESTAMP
);
