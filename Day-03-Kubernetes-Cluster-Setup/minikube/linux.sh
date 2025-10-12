#!/usr/bin/env bash
set -euo pipefail
sudo apt update && sudo apt install -y docker.io
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube start --driver=docker --kubernetes-version=v1.30.0
minikube addons enable ingress
minikube addons enable metrics-server
