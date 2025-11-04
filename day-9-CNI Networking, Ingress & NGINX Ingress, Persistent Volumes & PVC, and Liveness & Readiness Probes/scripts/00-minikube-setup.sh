
#!/usr/bin/env bash
set -euo pipefail
minikube start --cpus=4 --memory=6g
minikube addons enable ingress
minikube addons enable storage-provisioner
echo "Minikube + Ingress + Storage ready."
