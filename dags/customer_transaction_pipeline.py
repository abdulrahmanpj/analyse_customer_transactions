from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.hooks.gcs import GCSHook
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.providers.google.cloud.operators.dataflow import DataflowStartFlexTemplateOperator
from common.dag_config import get_config

CFG = get_config()
CONF = lambda key: "{{ dag_run.conf['" + key + "'] }}"

def verify_source_object(**context):
    uri = context["dag_run"].conf["input_uri"]
    bucket, obj = uri.removeprefix("gs://").split("/", 1)
    if not GCSHook().exists(bucket, obj):
        raise FileNotFoundError(uri)

def bq_call(task_id, dataset, procedure, args):
    return BigQueryInsertJobOperator(task_id=task_id, project_id=CFG["project_id"],
        configuration={"query":{"useLegacySql":False,"query":f"CALL `{CFG['project_id']}.{dataset}.{procedure}`({args})"}})

with DAG("customer_transaction_pipeline", start_date=datetime(2026,1,1), schedule=None,
         catchup=False, max_active_runs=1, default_args={"retries":2}) as dag:
    discover_source_files = PythonOperator(task_id="discover_source_files", python_callable=verify_source_object)
    parse_and_load_bronze = DataflowStartFlexTemplateOperator(
        task_id="parse_interleaved_and_load_bronze", project_id=CFG["project_id"], location=CFG["region"],
        body={"launchParameter":{"jobName":"customer-transactions-{{ ts_nodash }}",
          "containerSpecGcsPath":CFG["template"],
          "parameters":{"input_uri":CONF("input_uri"),"batch_id":CONF("batch_id"),
            "bronze_dataset":CFG["bronze_dataset"]},
          }})
    validate_bronze = bq_call("run_bronze_dq", CFG["dq_dataset"], "sp_run_data_quality_checks", f"'{CONF('batch_id')}','BRONZE'")
    transform_silver = bq_call("transform_silver", CFG["silver_dataset"], "sp_process_silver", f"'{CONF('batch_id')}'")
    validate_silver = bq_call("run_silver_dq", CFG["dq_dataset"], "sp_run_data_quality_checks", f"'{CONF('batch_id')}','SILVER'")
    merge_customer_scd2 = bq_call("merge_customer_scd2", CFG["gold_dataset"], "sp_merge_dim_customer_scd2", f"'{CONF('batch_id')}',TIMESTAMP('{CONF('batch_effective_ts')}')")
    merge_account_scd2 = bq_call("merge_account_scd2", CFG["gold_dataset"], "sp_merge_dim_account_scd2", f"'{CONF('batch_id')}',TIMESTAMP('{CONF('batch_effective_ts')}')")
    build_transaction_fact = bq_call("build_transaction_fact", CFG["gold_dataset"], "sp_build_gold", f"'{CONF('batch_id')}'")
    final_validation = bq_call("run_final_validation", CFG["dq_dataset"], "sp_run_data_quality_checks", f"'{CONF('batch_id')}','GOLD'")

    discover_source_files >> parse_and_load_bronze >> validate_bronze >> transform_silver >> validate_silver
    validate_silver >> [merge_customer_scd2, merge_account_scd2] >> build_transaction_fact >> final_validation
