#!/usr/bin/env bash
set -euo pipefail
PROJECT_ID="${PROJECT_ID:-dbs-data-ai-ai-core}"; REGION="${REGION:-us-central1}"
BUCKET="${DEPLOYMENT_BUCKET:-${PROJECT_ID}-pjabdulrahman-pipeline}"

gcloud config set project "$PROJECT_ID"
gcloud services enable bigquery.googleapis.com dataflow.googleapis.com composer.googleapis.com storage.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com compute.googleapis.com iam.googleapis.com
gcloud storage buckets describe "gs://$BUCKET" >/dev/null 2>&1 || gcloud storage buckets create "gs://$BUCKET" --location="$REGION" --uniform-bucket-level-access
gcloud artifacts repositories describe pjabdulrahman-data-pipelines --location="$REGION" >/dev/null 2>&1 || gcloud artifacts repositories create pjabdulrahman-data-pipelines --repository-format=docker --location="$REGION"
echo "Using the project's existing Google-managed/default service accounts."
