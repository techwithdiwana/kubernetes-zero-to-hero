# GCP Manual Cluster — Worker Join

Run this on `worker-1` and `worker-2` (use your token & hash from kubeadm init output):
```bash
sudo kubeadm join <CP-1_IP>:6443 --token <TOKEN>   --discovery-token-ca-cert-hash sha256:<HASH>
```
Validate:
```bash
kubectl get nodes -o wide
kubectl get pods -A
```
