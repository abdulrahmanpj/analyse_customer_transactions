from airflow.models import Variable

def get_config() -> dict:
    return {
        "project_id": Variable.get("bank_project_id", default_var="dbs-data-ai-ai-core"),
        "region": Variable.get("bank_region", default_var="us-central1"),
        "template": Variable.get("bank_dataflow_template"),
        "bronze_dataset": Variable.get("bank_bronze_dataset", default_var="pjabdulrahman_bronze"),
        "silver_dataset": Variable.get("bank_silver_dataset", default_var="pjabdulrahman_silver"),
        "gold_dataset": Variable.get("bank_gold_dataset", default_var="pjabdulrahman_gold"),
        "dq_dataset": Variable.get("bank_dq_dataset", default_var="pjabdulrahman_dq"),
    }
