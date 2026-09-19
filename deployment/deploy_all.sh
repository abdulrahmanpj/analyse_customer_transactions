#!/usr/bin/env bash
set -euo pipefail
export PROJECT_ID="${PROJECT_ID:-dbs-data-ai-ai-core}"
export REGION="${REGION:-us-central1}"
export BQ_LOCATION="${BQ_LOCATION:-us-central1}"
export COMPOSER_ENVIRONMENT="${COMPOSER_ENVIRONMENT:-pjabdulrahman-customer-transactions}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command -v gcloud >/dev/null || { echo "gcloud is required. Run this script from Google Cloud Shell."; exit 1; }
command -v bq >/dev/null || { echo "bq is required. Run this script from Google Cloud Shell."; exit 1; }
chmod +x "$ROOT_DIR"/deployment/*.sh "$ROOT_DIR"/deployment/dataflow/*.sh "$ROOT_DIR"/deployment/composer/*.sh

"$ROOT_DIR/deployment/create_gcp_resources.sh"

for dataset in bronze silver gold dq; do
  bq --location="$BQ_LOCATION" mk --dataset "${PROJECT_ID}:pjabdulrahman_${dataset}" 2>/dev/null || true
done

run_sql() { sed "s/\${PROJECT_ID}/${PROJECT_ID}/g" "$1" | bq --location="$BQ_LOCATION" query --use_legacy_sql=false; }
while IFS= read -r file; do run_sql "$file"; done < <(find "$ROOT_DIR/sql/ddl/dq" "$ROOT_DIR/sql/ddl/silver" "$ROOT_DIR/sql/ddl/gold" -name '*.sql' | sort)
run_sql "$ROOT_DIR/sql/ddl/bronze/create_bronze_customers.sql"
while IFS= read -r file; do [ "$file" = "$ROOT_DIR/sql/ddl/bronze/create_bronze_customers.sql" ] || run_sql "$file"; done < <(find "$ROOT_DIR/sql/ddl/bronze" -name '*.sql' | sort)

for folder in procedures views; do while IFS= read -r file; do run_sql "$file"; done < <(find "$ROOT_DIR/sql/$folder" -name '*.sql' | sort); done

"$ROOT_DIR/deployment/dataflow/build_flex_template.sh"
"$ROOT_DIR/deployment/composer/create_and_configure.sh"
echo "Deployment complete: project=$PROJECT_ID region=$REGION composer=$COMPOSER_ENVIRONMENT"
