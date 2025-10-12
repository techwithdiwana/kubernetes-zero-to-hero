
# 🚀 6 Ways to Create a Kubernetes Cluster — World‑Class Guide

![Kubernetes](https://img.shields.io/badge/Kubernetes-Clusters-blue?logo=kubernetes) 
![Env](https://img.shields.io/badge/Environment-Cloud%20%26%20OnPrem-green) 
![Use%20Cases](https://img.shields.io/badge/Use%20Cases-Dev%20%7C%20Test%20%7C%20Prod-yellow) 
![Platforms](https://img.shields.io/badge/Platforms-Linux%20%7C%20macOS%20%7C%20Windows-orange) 
![Author](https://img.shields.io/badge/Made%20By-Tech%20With%20Diwana-red)

---

## 🧭 Overview

This kit includes **six complete cluster setup paths** with OS‑specific local steps, cloud/on‑prem production, teardown, and helper scripts.
- **Local:** Minikube (single-node) • Kind (multi-node)
- **On‑Prem/VMs:** kubeadm (HA: 2 control‑planes + 3 workers sample)
- **AWS:** kOps (self‑managed IaC) • EKS (managed control plane)
- **Azure:** AKS (managed)
- **GCP:** GKE Autopilot (fully managed data + control plane)
- **Enterprise:** Cluster API (declarative lifecycle)

> Use this as a GitHub README or training handout. Scripts/YAMLs live in the folders.

---

## 🧩 1) Minikube — Local Development (OS‑Specific)

**Purpose:** Learning, quick POCs • **Prod:** ❌

### Linux
```bash
sudo apt update && sudo apt install -y docker.io
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube start --driver=docker --kubernetes-version=v1.30.0
minikube addons enable ingress
minikube addons enable metrics-server
```

### macOS
```bash
brew install minikube
minikube start --driver=docker --kubernetes-version=v1.30.0
minikube addons enable ingress
minikube addons enable metrics-server
```

### Windows (WSL2/Docker Desktop)
```powershell
choco install minikube -y
minikube start --driver=docker --kubernetes-version=v1.30.0
minikube addons enable ingress
minikube addons enable metrics-server
```

---

## 🔁 2) Kind — Local Multi‑Node (OS‑Specific)

**Purpose:** CI/CD, local multi‑node • **Prod:** ❌

Common multi‑node config (`kind/kind-config.yaml`):
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

Linux
```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind
kind create cluster --name dev --config kind/kind-config.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.1/deploy/static/provider/kind/deploy.yaml
```

macOS
```bash
brew install kind
kind create cluster --name dev --config kind/kind-config.yaml
```

Windows
```powershell
choco install kind -y
kind create cluster --name dev --config kind/kind-config.yaml
```

---

## 🏗️ 3) kubeadm — On‑Prem / VMs (Production HA sample)

**Topology:** 2× control‑planes (cp1, cp2) behind **HAProxy** + 3× workers (w1–w3)  
**LB:** 192.168.1.10:6443 • **Masters:** 192.168.1.11, .12 • **Workers:** .13–.15

Node prep (all nodes):
```bash
sudo swapoff -a && sudo sed -i '/ swap / s/^/#/' /etc/fstab
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay && sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
```

Container runtime + packages (Ubuntu example):
```bash
sudo apt update && sudo apt install -y containerd apt-transport-https ca-certificates curl
sudo mkdir -p /etc/containerd && sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl enable --now containerd
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/k8s.gpg
echo "deb [signed-by=/etc/apt/keyrings/k8s.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update && sudo apt install -y kubeadm kubelet kubectl && sudo apt-mark hold kubeadm kubelet kubectl
```

HAProxy (`kubeadm/haproxy.cfg`):
```cfg
frontend kubernetes
    bind *:6443
    mode tcp
    default_backend k8s_masters
backend k8s_masters
    mode tcp
    balance roundrobin
    option tcp-check
    server cp1 192.168.1.11:6443 check
    server cp2 192.168.1.12:6443 check
```

Control‑plane init (cp1):
```bash
sudo kubeadm init --control-plane-endpoint "192.168.1.10:6443" --upload-certs --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube && sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config && sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml
```

Join cp2:
```bash
sudo kubeadm init phase upload-certs --upload-certs  # on cp1
kubeadm token create --print-join-command            # on cp1
sudo kubeadm join 192.168.1.10:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash> --control-plane --certificate-key <cert-key>
```

Join workers:
```bash
sudo kubeadm join 192.168.1.10:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

---

## ☁️ 4) kOps — AWS (Self‑Managed IaC)

```bash
export AWS_REGION=ap-south-1
export KOPS_STATE_STORE=s3://kops-state-store
export CLUSTER_NAME=prod.k8s.example.com

kops create cluster   --name=${CLUSTER_NAME}   --state=${KOPS_STATE_STORE}   --zones=ap-south-1a,ap-south-1b,ap-south-1c   --master-size=t3.medium   --node-size=t3.large   --node-count=3   --topology=private   --networking=calico   --bastion

kops update cluster --name ${CLUSTER_NAME} --yes
kops validate cluster --wait 10m
```

---

## ☁️ 5) Managed Services — GKE / EKS / AKS

**GKE Autopilot (`managed/gke/commands.sh`)**
```bash
gcloud config set project <PROJECT_ID>
gcloud config set compute/region asia-south1
gcloud services enable container.googleapis.com compute.googleapis.com
gcloud container clusters create-auto prod-ap   --region=asia-south1   --release-channel=regular   --enable-private-nodes   --logging=SYSTEM,WORKLOAD   --monitoring=SYSTEM,WORKLOAD
gcloud container clusters get-credentials prod-ap --region=asia-south1
```

**EKS (`managed/eks/commands.sh`)**
```bash
eksctl create cluster   --name prod-eks   --region ap-south-1   --with-oidc   --nodegroup-name ng-1   --node-type t3.large   --nodes 3   --managed
aws eks update-kubeconfig --name prod-eks --region ap-south-1
```

**AKS (`managed/aks/commands.sh`)**
```bash
az group create -n rg-aks -l centralindia
az aks create -g rg-aks -n prod-aks --node-count 3 --node-vm-size Standard_D4s_v5 --enable-managed-identity
az aks get-credentials -g rg-aks -n prod-aks
```

---

## 🧱 6) Cluster API — Declarative Lifecycle

Bootstrap:
```bash
clusterctl init --infrastructure aws
```

Workload cluster definition (`cluster-api/cluster.yaml` excerpt):
```yaml
apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
  name: prod-capi-aws
spec:
  clusterNetwork:
    pods:
      cidrBlocks: ["192.168.0.0/16"]
  controlPlaneRef:
    apiVersion: controlplane.cluster.x-k8s.io/v1beta1
    kind: KubeadmControlPlane
    name: prod-capi-aws-control-plane
  infrastructureRef:
    apiVersion: infrastructure.cluster.x-k8s.io/v1beta2
    kind: AWSCluster
    name: prod-capi-aws
```

Get kubeconfig:
```bash
clusterctl get kubeconfig prod-capi-aws > kubeconfig-prod
KUBECONFIG=kubeconfig-prod kubectl get nodes
```

---

## 🧹 Teardown Snippets

```bash
minikube delete --all
kind delete cluster --name dev
kops delete cluster --name ${CLUSTER_NAME} --yes
gcloud container clusters delete prod-ap --region=asia-south1 --quiet
eksctl delete cluster --name prod-eks --region ap-south-1
az aks delete -g rg-aks -n prod-aks --yes
kubectl delete -f cluster-api/cluster.yaml
```

---

## 🏆 Made with ❤️ by **Tech With Diwana**
