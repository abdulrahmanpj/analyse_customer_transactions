CREATE TABLE IF NOT EXISTS `${PROJECT_ID}.pjabdulrahman_silver.silver_cards` (
  card_id INT64, account_id INT64, card_number_masked STRING, card_type STRING,
  issue_date DATE, expiry_date DATE, status STRING, batch_id STRING, processed_at TIMESTAMP
);
