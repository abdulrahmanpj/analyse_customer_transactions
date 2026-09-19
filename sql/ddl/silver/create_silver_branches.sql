CREATE TABLE IF NOT EXISTS `${PROJECT_ID}.pjabdulrahman_silver.silver_branches` (
  branch_id INT64, branch_name STRING, town STRING, county STRING, region STRING,
  sort_code_prefix STRING, open_date DATE, batch_id STRING, processed_at TIMESTAMP
);
