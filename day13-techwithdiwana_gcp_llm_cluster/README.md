
# 🚀 TechWithDiwana – GCP HA Kubernetes + LLM App (Zero to Hero)

![GCP](https://img.shields.io/badge/GCP-Compute-blue?style=flat-square)
![Kubernetes](https://img.shields.io/badge/Kubernetes-HA-blue?style=flat-square)
![Multi-Master](https://img.shields.io/badge/ControlPlane-Multi--Master-success?style=flat-square)
![HAProxy](https://img.shields.io/badge/HAProxy-TCP_LoadBalancer-orange?style=flat-square)
![Ingress](https://img.shields.io/badge/Ingress-NGINX-green?style=flat-square)
![SSL](https://img.shields.io/badge/SSL-Let%27sEncrypt-yellow?style=flat-square)
![Runtime](https://img.shields.io/badge/Runtime-containerd-important?style=flat-square)
![Docker](https://img.shields.io/badge/Docker-Build_Only-blue?style=flat-square)

---

## 📌 Architecture

```
Internet
 |
 | https://llm.techwithdiwana.com
 |
DNS (A Record)
 |
Static Public IP (GCP)
 |
HAProxy VM
 |-- 6443 → Kubernetes API (Multi-Master)
 |-- 80   → Ingress HTTP (cert-manager)
 |-- 443  → Ingress HTTPS (Application)
 |
NGINX Ingress Controller (NodePort)
 |
Kubernetes Services
 |
Pods (Frontend | Node.js | FastAPI)
```

---

## ⚠️ Important Notes (Must Read)

- Kubernetes runtime: **containerd**
- Docker is used **ONLY for image build**
- ❌ Do NOT build Docker images on Kubernetes nodes
- Docker images are built on **local system / Docker host**
- Images are already pushed to **Docker Hub**
- Kubernetes manifests already reference these images

---

# ===============================
# STEP 1: Install Google Cloud CLI
# ===============================

```powershell
winget install -e --id Google.CloudSDK
```

Restart PowerShell.

```powershell
gcloud version
gcloud init
gcloud config set project <YOUR_PROJECT_ID>
gcloud config set compute/region asia-south1
gcloud config set compute/zone asia-south1-a
gcloud services enable compute.googleapis.com iam.googleapis.com
gcloud config list
```

---

# PHASE 0 – SSH Key (Secure Access)

```powershell
ssh-keygen -t ed25519 -f $HOME\.ssh\gcp-techwithdiwana
cat $HOME\.ssh\gcp-techwithdiwana.pub
```

Add the public key in **GCP Console → VM → Edit → SSH Keys**.

```powershell
ssh -i $HOME\.ssh\gcp-techwithdiwana ubuntu@<VM_PUBLIC_IP>
```

---

# PHASE 1 – VM Creation (5 VMs)

```powershell
$ZONE="asia-south1-a"
$MACHINE="e2-medium"

foreach ($vm in "haproxy-1","k8s-master-1","k8s-master-2","k8s-worker-1","k8s-worker-2") {
  gcloud compute instances create $vm `
    --zone=$ZONE `
    --machine-type=$MACHINE `
    --image-family=ubuntu-2204-lts `
    --image-project=ubuntu-os-cloud `
    --boot-disk-size=50GB `
    --tags=k8s-node
}
```

---

# PHASE 2 – Firewall

```powershell
gcloud compute firewall-rules create allow-k8s-all `
  --allow="tcp:22,tcp:80,tcp:443,tcp:6443,tcp:30000-32767" `
  --source-ranges=0.0.0.0/0 `
  --target-tags=k8s-node
```

---

## NOTE
PHASE 3, PHASE 4, and PHASE 5 must be executed on **ALL Kubernetes nodes**.

---

# PHASE 3 – Linux Prep

```bash
sudo -i
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab
modprobe overlay
modprobe br_netfilter

cat <<EOF >/etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF

sysctl --system
```

---

# PHASE 4 – containerd Runtime

```bash
apt update
apt install -y containerd

mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sed -i 's|sandbox_image = .*|sandbox_image = "registry.k8s.io/pause:3.9"|' /etc/containerd/config.toml

systemctl daemon-reexec
systemctl restart containerd
systemctl enable containerd
```

---

# PHASE 5 – Kubernetes Binaries

```bash
apt install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key |
gpg --dearmor -o /etc/apt/keyrings/kubernetes.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" > /etc/apt/sources.list.d/kubernetes.list

apt update
apt install -y kubeadm kubelet kubectl
apt-mark hold kubeadm kubelet kubectl
```

---

# PHASE 6 – HAProxy (K8s API – 6443)

```bash
apt update
apt install -y haproxy
nano /etc/haproxy/haproxy.cfg
```

```cfg
frontend kubernetes
    bind *:6443
    mode tcp
    default_backend k8s-masters

backend k8s-masters
    mode tcp
    balance roundrobin
    server master1 <MASTER1_PRIVATE_IP>:6443 check
    server master2 <MASTER2_PRIVATE_IP>:6443 check
```

```bash
systemctl restart haproxy
systemctl enable haproxy
```

---

# PHASE 7 – kubeadm init (MASTER-1)

```bash
kubeadm init   --control-plane-endpoint "<HAPROXY_PRIVATE_IP>:6443"   --pod-network-cidr=10.244.0.0/16   --upload-certs
```

```bash
mkdir -p ~/.kube
cp /etc/kubernetes/admin.conf ~/.kube/config
chown $(id -u):$(id -g) ~/.kube/config
```

---

# PHASE 8 – Join Nodes

```bash
kubeadm join <HAPROXY_PRIVATE_IP>:6443   --control-plane   --token <TOKEN>   --discovery-token-ca-cert-hash sha256:<HASH>   --certificate-key <CERT_KEY>
```

```bash
kubeadm join <HAPROXY_PRIVATE_IP>:6443   --token <TOKEN>   --discovery-token-ca-cert-hash sha256:<HASH>
```

---

# PHASE 9 – CNI (Flannel)

```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
kubectl get nodes
```

---

# PHASE 10 – NGINX Ingress Controller

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.1/deploy/static/provider/baremetal/deploy.yaml
```

---

# PHASE 11 – cert-manager

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

---

# PHASE 11.5 – HAProxy Ingress (80 / 443)

```bash
kubectl get svc ingress-nginx-controller -n ingress-nginx
nano /etc/haproxy/haproxy.cfg
```

```cfg
frontend ingress_https
    bind *:443
    mode tcp
    default_backend ingress_https_back

backend ingress_https_back
    mode tcp
    balance roundrobin
    server worker1 <WORKER1_PRIVATE_IP>:<HTTPS_NODEPORT> check
    server worker2 <WORKER2_PRIVATE_IP>:<HTTPS_NODEPORT> check

frontend ingress_http
    bind *:80
    mode tcp
    default_backend ingress_http_back

backend ingress_http_back
    mode tcp
    balance roundrobin
    server worker1 <WORKER1_PRIVATE_IP>:<HTTP_NODEPORT> check
    server worker2 <WORKER2_PRIVATE_IP>:<HTTP_NODEPORT> check
```

```bash
systemctl restart haproxy
```

---

# PHASE 12 – Docker Image Build (LOCAL SYSTEM ONLY)

```bash
git clone https://github.com/techwithdiwana/kubernetes-zero-to-hero.git
cd kubernetes-zero-to-hero/day13-techwithdiwana_gcp_llm_cluster/backend-fastapi
docker build -t techwithdiwana/llm-fastapi:v1 .
docker push techwithdiwana/llm-fastapi:v1
```

Repeat the same for **Node.js** and **Frontend**.

---

# PHASE 13 – Application Deploy

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/
```

---

# PHASE 14 – DNS

Create an **A record**:

```
llm.techwithdiwana.com → <STATIC_PUBLIC_IP_OF_HA_PROXY>
```

---

# PHASE 15 – Let's Encrypt

```bash
kubectl apply -f letsencrypt-prod.yaml
kubectl describe clusterissuer letsencrypt-prod
```

---

# FINAL CHECK

```bash
kubectl get pods -A
kubectl get ingress -n techwithdiwana-llm-prod
```

Open:
👉 https://llm.techwithdiwana.com

---

# 🧹 CLEANUP (VERY IMPORTANT)

```powershell
gcloud compute instances delete haproxy-1 k8s-master-1 k8s-master-2 k8s-worker-1 k8s-worker-2 --zone=asia-south1-a --quiet
gcloud compute firewall-rules delete allow-k8s-all --quiet
gcloud compute addresses list
gcloud compute addresses delete <STATIC_IP_NAME> --region=asia-south1 --quiet
gcloud compute instances list
```

---

## 📜 License
MIT License – Tech With Diwana
