#!/usr/bin/env bash
set -euo pipefail
: "${RESOURCE_GROUP:=rg-aks}"
: "${CLUSTER_NAME:=prod-aks}"
: "${LOCATION:=centralindia}"
az group create -n "${RESOURCE_GROUP}" -l "${LOCATION}"
az aks create -g "${RESOURCE_GROUP}" -n "${CLUSTER_NAME}" --node-count 3 --node-vm-size Standard_D4s_v5 --enable-managed-identity
az aks get-credentials -g "${RESOURCE_GROUP}" -n "${CLUSTER_NAME}"
