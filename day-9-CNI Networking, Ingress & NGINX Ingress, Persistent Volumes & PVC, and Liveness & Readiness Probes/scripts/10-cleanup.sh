
#!/usr/bin/env bash
set -euo pipefail
kubectl delete ingress demo-ingress --ignore-not-found
kubectl delete svc app1 app2 --ignore-not-found
kubectl delete deploy app1 app2 --ignore-not-found
kubectl delete -f manifests/03-storage/pod-with-pvc.yaml --ignore-not-found
kubectl delete -f manifests/03-storage/pv-pvc-demo.yaml --ignore-not-found
kubectl delete -f manifests/04-probes/probes-demo.yaml --ignore-not-found
