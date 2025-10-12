#!/usr/bin/env bash
set -euo pipefail
brew install minikube
minikube start --driver=docker --kubernetes-version=v1.30.0
minikube addons enable ingress
minikube addons enable metrics-server
