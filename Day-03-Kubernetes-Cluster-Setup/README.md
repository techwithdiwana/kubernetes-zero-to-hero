# 🚀 Day-3: Kubernetes Cluster Setup — GCP (Manual kubeadm) & On‑Prem HA

![Kubernetes](https://img.shields.io/badge/Kubernetes-kubeadm-blue?style=for-the-badge&logo=kubernetes) ![GCP](https://img.shields.io/badge/Google_Cloud-Compute_Engine-red?style=for-the-badge&logo=googlecloud) ![On-Prem](https://img.shields.io/badge/On--Prem-HA_Cluster-grey?style=for-the-badge) ![CNI](https://img.shields.io/badge/CNI-Calico-orange?style=for-the-badge) ![CRI](https://img.shields.io/badge/CRI-containerd-green?style=for-the-badge) ![License](https://img.shields.io/badge/License-MIT-success?style=for-the-badge) ![Tech With Diwana](https://img.shields.io/badge/Tech_With_Diwana-YouTube-black?style=for-the-badge&logo=youtube)

A **world‑class**, copy‑paste ready guide for **manual Kubernetes clusters** using `kubeadm`:

- **GCP (3 nodes):** `1 control-plane + 2 workers`
- **On‑Prem HA (5 nodes):** `2 control-planes + 3 workers` with **kube‑vip VIP** (stacked etcd)

> If you want a managed option too, see: [`GKE Autopilot Quickstart`](./GKE-Autopilot-Quickstart/README.md)

---

## 📑 Table of Contents
- [Prerequisites (All Nodes)](#-prerequisites-all-nodes)
- [A) GCP Manual Cluster — 3 Nodes](#a-gcp-manual-cluster--3-nodes)
- [B) On‑Prem HA Cluster — 2 Masters + 3 Workers](#b-onprem-ha-cluster--2-masters--3-workers)
- [Firewall / Ports](#-firewall--ports)
- [Best Practices](#-best-practices)
- [Test App](#-test-app)
- [Cleanup](#-cleanup)
- [Credits & License](#-credits--license)

---

## 🧰 Prerequisites (All Nodes)
- **Ubuntu 22.04 LTS**
- Passwordless `sudo` user
- **Disable swap**, enable kernel modules, configure containerd, and install `kubeadm`, `kubelet`, `kubectl` (same minor version; e.g. **1.30.x**).

```bash
# Hostname (example per node)
sudo hostnamectl set-hostname <cp-1|cp-2|worker-1|worker-2|worker-3>

# /etc/hosts (sample)
cat <<'EOF' | sudo tee -a /etc/hosts
10.0.0.11  cp-1
10.0.0.12  cp-2
10.0.0.21  worker-1
10.0.0.22  worker-2
10.0.0.23  worker-3
EOF

# Turn off swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Kernel modules & sysctl
cat <<'EOF' | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<'EOF' | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF
sudo sysctl --system

# containerd
sudo apt-get update && sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl enable --now containerd

# kubeadm/kubelet/kubectl (1.30 stable repo)
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

> **CNI:** We use **Calico**. Pod CIDR: `192.168.0.0/16`.

---

## A) GCP Manual Cluster — 3 Nodes
**Topology:** `cp-1` (control-plane), `worker-1`, `worker-2`

### 1) Provision VMs (Compute Engine)
- Zone: cost‑effective (e.g., `us-central1-a`)
- Machine type: `e2-medium` (dev) or higher
- Disk: 30GB, Ubuntu 22.04
- **Firewall to cp-1:** TCP `6443`; NodePort `30000‑32767`; SSH `22`; intra‑subnet open

### 2) Initialize Control Plane (cp-1)
```bash
sudo kubeadm init   --pod-network-cidr=192.168.0.0/16   --apiserver-advertise-address=$(hostname -I | awk '{print $1}')
```

Save the **join** commands printed.

Configure kubectl:
```bash
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 3) Install Calico CNI
```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml
kubectl -n kube-system get pods
```

### 4) Join Workers
```bash
# On worker-1 and worker-2 (use your token/hash from kubeadm init)
sudo kubeadm join <CP-1_IP>:6443 --token <TOKEN>   --discovery-token-ca-cert-hash sha256:<HASH>
```

### 5) Validate & Smoke Test
```bash
kubectl get nodes -o wide
kubectl get pods -A

# Test app
kubectl apply -f ./Test-App/deployment.yaml
kubectl apply -f ./Test-App/service.yaml
kubectl get svc -o wide -n default
```

---

## B) On‑Prem HA Cluster — 2 Masters + 3 Workers (kube‑vip VIP)
**Plan:** VIP `10.0.0.100` on interface (e.g., `ens160`).

### 1) Prepare kube‑vip Static Pod (on cp-1 & cp-2)
Edit interface name + VIP in this file:
- [`OnPrem-HA-Cluster/kube-vip.yaml`](./OnPrem-HA-Cluster/kube-vip.yaml)

Place it as a static pod:
```bash
sudo mkdir -p /etc/kubernetes/manifests
sudo cp OnPrem-HA-Cluster/kube-vip.yaml /etc/kubernetes/manifests/kube-vip.yaml
```

### 2) Initialize First Control Plane (cp-1)
```bash
sudo kubeadm init   --control-plane-endpoint "10.0.0.100:6443"   --upload-certs   --pod-network-cidr=192.168.0.0/16
```

Configure kubectl on cp‑1 (same as above), then install Calico:
```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml
```

### 3) Join Second Control Plane (cp-2)
Use the **control-plane join** command from `kubeadm init` output (has `--certificate-key`), e.g.:
```bash
sudo kubeadm join 10.0.0.100:6443 --token <TOKEN>   --discovery-token-ca-cert-hash sha256:<HASH>   --control-plane --certificate-key <CERT_KEY>
```

### 4) Join Workers (3 nodes)
```bash
sudo kubeadm join 10.0.0.100:6443 --token <TOKEN>   --discovery-token-ca-cert-hash sha256:<HASH>
```

### 5) Validate HA
```bash
kubectl get nodes -o wide
kubectl -n kube-system get pods | grep kube-vip
# Temporarily stop cp-1 and verify the API via 10.0.0.100 still works.
```

---

## 🔒 Firewall / Ports
- API server: **6443/TCP** (to control planes)
- etcd peer & client (between control planes): **2379‑2380/TCP**
- Kubelet: **10250/TCP**; controller‑manager: **10257/TCP**; scheduler: **10259/TCP**
- NodePort range (apps): **30000‑32767/TCP**
- Calico optional BGP: **179/TCP**

---

## 🧠 Best Practices
- Same minor versions across `kubeadm/kubelet/kubectl`
- `SystemdCgroup=true` in containerd (already set above)
- Time sync enabled (chrony/systemd‑timesyncd)
- Taints/labels for control‑planes vs workers:
```bash
kubectl taint nodes cp-1 node-role.kubernetes.io/control-plane=:NoSchedule
kubectl label node worker-1 node-role.kubernetes.io/worker=""
```

---

## 🧪 Test App
Minimal NGINX deployment and NodePort service are in [`./Test-App`](./Test-App).

---

## 🧹 Cleanup
- **GCP (3‑node):** drain/delete nodes → `kubeadm reset -f` on each → delete VMs.
- **On‑Prem HA:** drain workers → delete nodes → drain CPs → `kubeadm reset -f` on all.

Detailed steps:
- [`GCP-Manual-Cluster/cleanup.md`](./GCP-Manual-Cluster/cleanup.md)
- [`OnPrem-HA-Cluster/cleanup.md`](./OnPrem-HA-Cluster/cleanup.md)

---

## ❤️ Credits & License
Made with ❤️ by **Tech With Diwana** • Subscribe: `https://youtube.com/@techwithdiwana`

This project is licensed under the **MIT License**. See [`LICENSE`](./LICENSE).
