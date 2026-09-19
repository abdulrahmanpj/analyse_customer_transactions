CREATE TABLE IF NOT EXISTS `${PROJECT_ID}.pjabdulrahman_silver.silver_loans` (
  loan_id INT64, customer_id INT64, branch_id INT64, loan_type STRING,
  principal_amount NUMERIC, interest_rate NUMERIC, term_months INT64,
  start_date DATE, status STRING, batch_id STRING, processed_at TIMESTAMP
);
