# GCP Manual Cluster — Cluster Init

1) Provision 3 VMs: `cp-1`, `worker-1`, `worker-2` (Ubuntu 22.04).
2) Open firewall to cp-1: 6443/TCP, 30000-32767/TCP, 22/TCP.
3) Run prerequisites on all nodes (see root README).
4) On `cp-1`:
```bash
sudo kubeadm init   --pod-network-cidr=192.168.0.0/16   --apiserver-advertise-address=$(hostname -I | awk '{print $1}')
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml
```
Save the join command displayed.
