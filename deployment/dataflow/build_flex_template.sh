#!/usr/bin/env bash
set -euo pipefail
PROJECT_ID="${PROJECT_ID:-dbs-data-ai-ai-core}"; REGION="${REGION:-us-central1}"
BUCKET="${DEPLOYMENT_BUCKET:-${PROJECT_ID}-pjabdulrahman-pipeline}"
IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/pjabdulrahman-data-pipelines/customer-transactions:latest"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
gcloud builds submit "$ROOT_DIR" \
  --region="$REGION" \
  --gcs-source-staging-dir="gs://${BUCKET}/cloud-build/source" \
  --gcs-log-dir="gs://${BUCKET}/cloud-build/logs" \
  --tag="$IMAGE"
gcloud dataflow flex-template build "gs://${BUCKET}/templates/customer-transaction-ingestion.json" --image="$IMAGE" --sdk-language=PYTHON --metadata-file="$ROOT_DIR/flex-template-metadata.json"
