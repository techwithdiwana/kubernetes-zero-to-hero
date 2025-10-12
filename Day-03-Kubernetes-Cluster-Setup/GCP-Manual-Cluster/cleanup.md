# GCP Manual Cluster — Cleanup

On control-plane:
```bash
kubectl drain worker-1 --ignore-daemonsets --delete-emptydir-data
kubectl drain worker-2 --ignore-daemonsets --delete-emptydir-data
kubectl delete node worker-1 worker-2
```

On each node (including cp-1):
```bash
sudo kubeadm reset -f
sudo systemctl restart containerd
sudo rm -rf ~/.kube
```

Delete VMs from GCP Console.
