# Analyze Customer Transactions

Minimal hackathon pipeline: GCS → Dataflow parser → Bronze → BigQuery SQL Silver → Gold SCD2/KPIs, orchestrated by Composer.

See [architecture](docs/architecture.md). The single deployment entry point is `deployment/deploy_all.sh`.

It defaults to project `dbs-data-ai-ai-core`, region/location `us-central1`, Composer environment `pjabdulrahman-customer-transactions`, and creates:

- required APIs, deployment bucket, and Artifact Registry;
- `pjabdulrahman_bronze`, `pjabdulrahman_silver`, `pjabdulrahman_gold`, and `pjabdulrahman_dq`;
- tables and separately defined procedures and views;
- the Dataflow Flex Template; and
- Cloud Composer plus Airflow variables and DAG upload.

The only parser configuration is `config/entities.yaml`. It supplies entity names, expected column counts, and business keys without requiring metadata datasets or seed scripts.

Run from Google Cloud Shell:

```bash
chmod +x deployment/deploy_all.sh
./deployment/deploy_all.sh
```

## Required analytical KPIs

Deployment creates these separate BigQuery views in `pjabdulrahman_gold`:

| Requirement | BigQuery view |
|---|---|
| Top 5 customers by money moved | `vw_top_5_customers_by_transaction_value` |
| Account-type transaction value contribution | `vw_product_revenue_contribution` |
| Accounts inactive for three months | `vw_inactive_accounts` |
| GBP transactions over £100,000 | `vw_suspicious_transactions` |
| Customer and account SCD Type 2 history | `vw_customer_account_history` |
| Loan portfolio and repayment health | `vw_loan_repayment_health` |
| Active-card adoption and cross-sell candidates | `vw_card_product_adoption` |

Run all KPI checks after the Day 0 DAG succeeds:

```bash
bq query --use_legacy_sql=false \
  'SELECT * FROM `dbs-data-ai-ai-core.pjabdulrahman_gold.vw_top_5_customers_by_transaction_value`'

bq query --use_legacy_sql=false \
  'SELECT * FROM `dbs-data-ai-ai-core.pjabdulrahman_gold.vw_product_revenue_contribution` ORDER BY gross_value_contribution_percentage DESC'

bq query --use_legacy_sql=false \
  'SELECT * FROM `dbs-data-ai-ai-core.pjabdulrahman_gold.vw_inactive_accounts`'

bq query --use_legacy_sql=false \
  'SELECT * FROM `dbs-data-ai-ai-core.pjabdulrahman_gold.vw_suspicious_transactions` ORDER BY ABS(amount) DESC'

bq query --use_legacy_sql=false \
  'SELECT * FROM `dbs-data-ai-ai-core.pjabdulrahman_gold.vw_customer_account_history` ORDER BY customer_id, customer_effective_from'

bq query --use_legacy_sql=false \
  'SELECT * FROM `dbs-data-ai-ai-core.pjabdulrahman_gold.vw_loan_repayment_health` ORDER BY outstanding_due DESC'

bq query --use_legacy_sql=false \
  'SELECT * FROM `dbs-data-ai-ai-core.pjabdulrahman_gold.vw_card_product_adoption` ORDER BY customer_id'
```

The product contribution view reports both signed net value and absolute gross
money movement. The percentage uses gross money movement so debits and credits
do not cancel each other. Inactive accounts use the query processing date as
the reference date. A customer with no active card is labelled
`CROSS_SELL_CANDIDATE_NO_ACTIVE_CARD`; this is a transparent working business
rule, not a predictive score.
