# Architecture
Dataflow handles only GCS interleaved parsing and Bronze landing. BigQuery stored procedures handle Silver typing/DQ and Gold SCD2/fact merges. Composer orchestrates the dependency chain in `dags/customer_transaction_pipeline.py`.
