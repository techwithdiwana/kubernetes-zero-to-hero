
# Troubleshooting Guide

## Ingress 404
- Ensure addon enabled and controller Ready:
  - `minikube addons enable ingress`
  - `kubectl -n ingress-nginx get pods`
- Verify hosts entry (`myapp.local` → 127.0.0.1).

## Hosts entry ignored (Windows)
- Run editor as **Administrator** to modify the hosts file.

## PVC Pending
- Check storage provisioner: `kubectl -n kube-system get pods | grep storage`
- Ensure StorageClass exists; Minikube's default should be present.

## Probes failing continuously
- Increase `initialDelaySeconds` to give the container time to boot.
- Confirm `path` and `port` are correct for your container.
