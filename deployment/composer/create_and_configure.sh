#!/usr/bin/env bash
set -euo pipefail
PROJECT_ID="${PROJECT_ID:-dbs-data-ai-ai-core}"; REGION="${REGION:-us-central1}"
ENVIRONMENT="${COMPOSER_ENVIRONMENT:-pjabdulrahman-customer-transactions}"
BUCKET="${DEPLOYMENT_BUCKET:-${PROJECT_ID}-pjabdulrahman-pipeline}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
gcloud composer environments describe "$ENVIRONMENT" --location="$REGION" >/dev/null 2>&1 || gcloud composer environments create "$ENVIRONMENT" --location="$REGION"
for pair in "bank_project_id=$PROJECT_ID" "bank_region=$REGION" "bank_dataflow_template=gs://${BUCKET}/templates/customer-transaction-ingestion.json"; do gcloud composer environments run "$ENVIRONMENT" --location="$REGION" variables -- --set "${pair%%=*}" "${pair#*=}"; done
gcloud composer environments storage dags import --environment="$ENVIRONMENT" --location="$REGION" --source="$ROOT_DIR/dags/customer_transaction_pipeline.py"
gcloud composer environments storage dags import --environment="$ENVIRONMENT" --location="$REGION" --source="$ROOT_DIR/dags/common"
