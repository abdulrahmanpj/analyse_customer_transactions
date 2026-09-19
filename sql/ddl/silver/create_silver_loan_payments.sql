CREATE TABLE IF NOT EXISTS `${PROJECT_ID}.pjabdulrahman_silver.silver_loan_payments` (
  payment_id INT64, loan_id INT64, due_date DATE, payment_date DATE,
  amount_due NUMERIC, amount_paid NUMERIC, payment_status STRING,
  batch_id STRING, processed_at TIMESTAMP
);
