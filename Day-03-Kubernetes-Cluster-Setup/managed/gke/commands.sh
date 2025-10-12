#!/usr/bin/env bash
set -euo pipefail
gcloud config set project "${PROJECT_ID:?}"
gcloud config set compute/region "${REGION:-asia-south1}"
gcloud services enable container.googleapis.com compute.googleapis.com
gcloud container clusters create-auto "${CLUSTER_NAME:-prod-ap}"   --region="${REGION:-asia-south1}"   --release-channel=regular   --enable-private-nodes   --logging=SYSTEM,WORKLOAD   --monitoring=SYSTEM,WORKLOAD
gcloud container clusters get-credentials "${CLUSTER_NAME:-prod-ap}" --region="${REGION:-asia-south1}"
