#!/usr/bin/env bash
set -euo pipefail
: "${REGION:=ap-south-1}"
: "${CLUSTER_NAME:=prod-eks}"
eksctl create cluster   --name "${CLUSTER_NAME}"   --region "${REGION}"   --with-oidc   --nodegroup-name ng-1   --node-type t3.large   --nodes 3   --managed
aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${REGION}"
