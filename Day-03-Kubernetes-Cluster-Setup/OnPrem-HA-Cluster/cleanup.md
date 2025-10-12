# On‑Prem HA — Cleanup

On a master:
```bash
kubectl drain worker-1 --ignore-daemonsets --delete-emptydir-data
kubectl drain worker-2 --ignore-daemonsets --delete-emptydir-data
kubectl drain worker-3 --ignore-daemonsets --delete-emptydir-data
kubectl delete node worker-1 worker-2 worker-3
kubectl drain cp-2 --ignore-daemonsets --delete-emptydir-data
kubectl delete node cp-2
kubectl drain cp-1 --ignore-daemonsets --delete-emptydir-data
kubectl delete node cp-1
```

On each node:
```bash
sudo kubeadm reset -f
sudo systemctl restart containerd
sudo rm -rf ~/.kube
```
