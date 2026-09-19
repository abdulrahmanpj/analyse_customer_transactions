CREATE OR REPLACE VIEW `${PROJECT_ID}.pjabdulrahman_gold.vw_loan_repayment_health` AS
WITH loans AS (
    SELECT *
    FROM `${PROJECT_ID}.pjabdulrahman_silver.silver_loans`
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY loan_id ORDER BY processed_at DESC
    ) = 1
), payments AS (
    SELECT *
    FROM `${PROJECT_ID}.pjabdulrahman_silver.silver_loan_payments`
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY payment_id ORDER BY processed_at DESC
    ) = 1
), branches AS (
    SELECT *
    FROM `${PROJECT_ID}.pjabdulrahman_silver.silver_branches`
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY branch_id ORDER BY processed_at DESC
    ) = 1
), repayment_summary AS (
    SELECT
        l.loan_id,
        l.customer_id,
        l.branch_id,
        b.branch_name,
        l.loan_type,
        l.principal_amount,
        l.status AS loan_status,
        COUNT(p.payment_id) AS payment_count,
        SUM(IFNULL(p.amount_due, 0)) AS total_due,
        SUM(IFNULL(p.amount_paid, 0)) AS total_paid,
        SUM(IFNULL(p.amount_due, 0) - IFNULL(p.amount_paid, 0)) AS outstanding_due,
        COUNTIF(p.payment_status = 'Late') AS late_payment_count,
        COUNTIF(p.payment_status = 'Missed') AS missed_payment_count,
        COUNTIF(p.payment_status = 'Partial') AS partial_payment_count
    FROM loans l
    LEFT JOIN payments p USING(loan_id)
    LEFT JOIN branches b USING(branch_id)
    GROUP BY
        l.loan_id,
        l.customer_id,
        l.branch_id,
        b.branch_name,
        l.loan_type,
        l.principal_amount,
        l.status
)
SELECT
    *,
    CASE
        WHEN loan_status IN ('Default', 'Delinquent')
            OR missed_payment_count > 0
            OR partial_payment_count > 0
            OR outstanding_due > 0
            THEN 'ATTENTION_REQUIRED'
        WHEN late_payment_count > 0 THEN 'LATE_PAYMENT_HISTORY'
        ELSE 'NO_REPAYMENT_ISSUE_OBSERVED'
    END AS repayment_health
FROM repayment_summary;
