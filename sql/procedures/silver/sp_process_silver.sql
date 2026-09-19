CREATE OR REPLACE PROCEDURE `${PROJECT_ID}.pjabdulrahman_silver.sp_process_silver`(p_batch_id STRING)
BEGIN
  MERGE `${PROJECT_ID}.pjabdulrahman_silver.silver_customers` t
  USING (
    SELECT SAFE_CAST(JSON_VALUE(payload,'$.CustomerID') AS INT64) customer_id,
      JSON_VALUE(payload,'$.FirstName') first_name, JSON_VALUE(payload,'$.LastName') last_name,
      JSON_VALUE(payload,'$.Email') email, JSON_VALUE(payload,'$.Phone') phone,
      JSON_VALUE(payload,'$.AddressLine1') address_line_1,
      JSON_VALUE(payload,'$.CustomerSegment') customer_segment,
      JSON_VALUE(payload,'$.KYCStatus') kyc_status, batch_id, CURRENT_TIMESTAMP() processed_at
    FROM `${PROJECT_ID}.pjabdulrahman_bronze.bronze_customers`
    WHERE batch_id = p_batch_id
    QUALIFY ROW_NUMBER() OVER(PARTITION BY batch_id, JSON_VALUE(payload,'$.CustomerID') ORDER BY record_number DESC) = 1
  ) s ON t.customer_id = s.customer_id AND t.batch_id = s.batch_id
  WHEN NOT MATCHED THEN INSERT ROW;

  MERGE `${PROJECT_ID}.pjabdulrahman_silver.silver_accounts` t
  USING (
    SELECT SAFE_CAST(JSON_VALUE(payload,'$.AccountID') AS INT64) account_id,
      SAFE_CAST(JSON_VALUE(payload,'$.CustomerID') AS INT64) customer_id,
      SAFE_CAST(JSON_VALUE(payload,'$.BranchID') AS INT64) branch_id,
      SAFE_CAST(JSON_VALUE(payload,'$.AccountTypeID') AS INT64) account_type_id,
      JSON_VALUE(payload,'$.SortCode') sort_code,
      SAFE_CAST(SUBSTR(JSON_VALUE(payload,'$.OpenDate'),1,10) AS DATE) open_date,
      SAFE_CAST(SUBSTR(JSON_VALUE(payload,'$.CloseDate'),1,10) AS DATE) close_date,
      JSON_VALUE(payload,'$.Status') status,
      SAFE_CAST(JSON_VALUE(payload,'$.CurrentBalance') AS NUMERIC) current_balance,
      JSON_VALUE(payload,'$.Currency') currency, batch_id, CURRENT_TIMESTAMP() processed_at
    FROM `${PROJECT_ID}.pjabdulrahman_bronze.bronze_accounts`
    WHERE batch_id = p_batch_id
    QUALIFY ROW_NUMBER() OVER(PARTITION BY batch_id, JSON_VALUE(payload,'$.AccountID') ORDER BY record_number DESC) = 1
  ) s ON t.account_id = s.account_id AND t.batch_id = s.batch_id
  WHEN NOT MATCHED THEN INSERT ROW;

  MERGE `${PROJECT_ID}.pjabdulrahman_silver.silver_transactions` t
  USING (
    SELECT SAFE_CAST(JSON_VALUE(payload,'$.TransactionID') AS INT64) transaction_id,
      SAFE_CAST(JSON_VALUE(payload,'$.AccountID') AS INT64) account_id,
      SAFE_CAST(JSON_VALUE(payload,'$.TransactionTypeID') AS INT64) transaction_type_id,
      SAFE_CAST(JSON_VALUE(payload,'$.TransactionDateTime') AS TIMESTAMP) transaction_datetime,
      SAFE_CAST(JSON_VALUE(payload,'$.Amount') AS NUMERIC) amount,
      JSON_VALUE(payload,'$.Currency') currency, JSON_VALUE(payload,'$.Channel') channel,
      NULLIF(JSON_VALUE(payload,'$.MerchantCategory'),'') merchant_category,
      batch_id, CURRENT_TIMESTAMP() processed_at
    FROM `${PROJECT_ID}.pjabdulrahman_bronze.bronze_transactions`
    WHERE batch_id = p_batch_id
    QUALIFY ROW_NUMBER() OVER(PARTITION BY JSON_VALUE(payload,'$.TransactionID') ORDER BY record_number DESC) = 1
  ) s ON t.transaction_id = s.transaction_id
  WHEN NOT MATCHED THEN INSERT ROW;

  MERGE `${PROJECT_ID}.pjabdulrahman_silver.silver_account_types` t
  USING (
    SELECT SAFE_CAST(JSON_VALUE(payload,'$.AccountTypeID') AS INT64) account_type_id,
      JSON_VALUE(payload,'$.TypeName') type_name,
      SAFE_CAST(JSON_VALUE(payload,'$.InterestRate') AS NUMERIC) interest_rate,
      SAFE_CAST(JSON_VALUE(payload,'$.MinBalance') AS NUMERIC) min_balance,
      SAFE_CAST(JSON_VALUE(payload,'$.OverdraftLimit') AS NUMERIC) overdraft_limit,
      batch_id, CURRENT_TIMESTAMP() processed_at
    FROM `${PROJECT_ID}.pjabdulrahman_bronze.bronze_accounttypes`
    WHERE batch_id = p_batch_id
    QUALIFY ROW_NUMBER() OVER(PARTITION BY batch_id, JSON_VALUE(payload,'$.AccountTypeID') ORDER BY record_number DESC) = 1
  ) s ON t.account_type_id = s.account_type_id AND t.batch_id = s.batch_id
  WHEN NOT MATCHED THEN INSERT ROW;

  MERGE `${PROJECT_ID}.pjabdulrahman_silver.silver_transaction_types` t
  USING (
    SELECT SAFE_CAST(JSON_VALUE(payload,'$.TransactionTypeID') AS INT64) transaction_type_id,
      JSON_VALUE(payload,'$.TypeName') type_name, JSON_VALUE(payload,'$.Category') category,
      batch_id, CURRENT_TIMESTAMP() processed_at
    FROM `${PROJECT_ID}.pjabdulrahman_bronze.bronze_transactiontypes`
    WHERE batch_id = p_batch_id
    QUALIFY ROW_NUMBER() OVER(PARTITION BY batch_id, JSON_VALUE(payload,'$.TransactionTypeID') ORDER BY record_number DESC) = 1
  ) s ON t.transaction_type_id = s.transaction_type_id AND t.batch_id = s.batch_id
  WHEN NOT MATCHED THEN INSERT ROW;

  MERGE `${PROJECT_ID}.pjabdulrahman_silver.silver_branches` t
  USING (
    SELECT SAFE_CAST(JSON_VALUE(payload,'$.BranchID') AS INT64) branch_id,
      JSON_VALUE(payload,'$.BranchName') branch_name, JSON_VALUE(payload,'$.Town') town,
      JSON_VALUE(payload,'$.County') county, JSON_VALUE(payload,'$.Region') region,
      JSON_VALUE(payload,'$.SortCodePrefix') sort_code_prefix,
      SAFE_CAST(SUBSTR(JSON_VALUE(payload,'$.OpenDate'),1,10) AS DATE) open_date,
      batch_id, CURRENT_TIMESTAMP() processed_at
    FROM `${PROJECT_ID}.pjabdulrahman_bronze.bronze_branches`
    WHERE batch_id = p_batch_id
    QUALIFY ROW_NUMBER() OVER(PARTITION BY batch_id, JSON_VALUE(payload,'$.BranchID') ORDER BY record_number DESC) = 1
  ) s ON t.branch_id = s.branch_id AND t.batch_id = s.batch_id
  WHEN NOT MATCHED THEN INSERT ROW;

  MERGE `${PROJECT_ID}.pjabdulrahman_silver.silver_cards` t
  USING (
    SELECT SAFE_CAST(JSON_VALUE(payload,'$.CardID') AS INT64) card_id,
      SAFE_CAST(JSON_VALUE(payload,'$.AccountID') AS INT64) account_id,
      JSON_VALUE(payload,'$.CardNumberMasked') card_number_masked,
      JSON_VALUE(payload,'$.CardType') card_type,
      SAFE_CAST(SUBSTR(JSON_VALUE(payload,'$.IssueDate'),1,10) AS DATE) issue_date,
      SAFE_CAST(SUBSTR(JSON_VALUE(payload,'$.ExpiryDate'),1,10) AS DATE) expiry_date,
      JSON_VALUE(payload,'$.Status') status, batch_id, CURRENT_TIMESTAMP() processed_at
    FROM `${PROJECT_ID}.pjabdulrahman_bronze.bronze_cards`
    WHERE batch_id = p_batch_id
    QUALIFY ROW_NUMBER() OVER(PARTITION BY batch_id, JSON_VALUE(payload,'$.CardID') ORDER BY record_number DESC) = 1
  ) s ON t.card_id = s.card_id AND t.batch_id = s.batch_id
  WHEN NOT MATCHED THEN INSERT ROW;

  MERGE `${PROJECT_ID}.pjabdulrahman_silver.silver_loans` t
  USING (
    SELECT SAFE_CAST(JSON_VALUE(payload,'$.LoanID') AS INT64) loan_id,
      SAFE_CAST(JSON_VALUE(payload,'$.CustomerID') AS INT64) customer_id,
      SAFE_CAST(JSON_VALUE(payload,'$.BranchID') AS INT64) branch_id,
      JSON_VALUE(payload,'$.LoanType') loan_type,
      SAFE_CAST(JSON_VALUE(payload,'$.PrincipalAmount') AS NUMERIC) principal_amount,
      SAFE_CAST(JSON_VALUE(payload,'$.InterestRate') AS NUMERIC) interest_rate,
      SAFE_CAST(JSON_VALUE(payload,'$.TermMonths') AS INT64) term_months,
      SAFE_CAST(SUBSTR(JSON_VALUE(payload,'$.StartDate'),1,10) AS DATE) start_date,
      JSON_VALUE(payload,'$.Status') status, batch_id, CURRENT_TIMESTAMP() processed_at
    FROM `${PROJECT_ID}.pjabdulrahman_bronze.bronze_loans`
    WHERE batch_id = p_batch_id
    QUALIFY ROW_NUMBER() OVER(PARTITION BY batch_id, JSON_VALUE(payload,'$.LoanID') ORDER BY record_number DESC) = 1
  ) s ON t.loan_id = s.loan_id AND t.batch_id = s.batch_id
  WHEN NOT MATCHED THEN INSERT ROW;

  MERGE `${PROJECT_ID}.pjabdulrahman_silver.silver_loan_payments` t
  USING (
    SELECT SAFE_CAST(JSON_VALUE(payload,'$.PaymentID') AS INT64) payment_id,
      SAFE_CAST(JSON_VALUE(payload,'$.LoanID') AS INT64) loan_id,
      SAFE_CAST(SUBSTR(JSON_VALUE(payload,'$.DueDate'),1,10) AS DATE) due_date,
      SAFE_CAST(SUBSTR(JSON_VALUE(payload,'$.PaymentDate'),1,10) AS DATE) payment_date,
      SAFE_CAST(JSON_VALUE(payload,'$.AmountDue') AS NUMERIC) amount_due,
      SAFE_CAST(JSON_VALUE(payload,'$.AmountPaid') AS NUMERIC) amount_paid,
      JSON_VALUE(payload,'$.PaymentStatus') payment_status,
      batch_id, CURRENT_TIMESTAMP() processed_at
    FROM `${PROJECT_ID}.pjabdulrahman_bronze.bronze_loanpayments`
    WHERE batch_id = p_batch_id
    QUALIFY ROW_NUMBER() OVER(PARTITION BY batch_id, JSON_VALUE(payload,'$.PaymentID') ORDER BY record_number DESC) = 1
  ) s ON t.payment_id = s.payment_id AND t.batch_id = s.batch_id
  WHEN NOT MATCHED THEN INSERT ROW;
END;
