
# 🚀 TechWithDiwana – GCP HA Kubernetes + LLM Application  
**Day-13 | Kubernetes Zero → Hero (Industry Grade, A–Z Setup)**

![GCP](https://img.shields.io/badge/GCP-Cloud-blue?logo=googlecloud)
![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.29-blue?logo=kubernetes)
![HAProxy](https://img.shields.io/badge/HAProxy-TCP%20LoadBalancer-orange)
![NGINX](https://img.shields.io/badge/NGINX-Ingress-green)
![cert-manager](https://img.shields.io/badge/cert--manager-SSL-success)
![FastAPI](https://img.shields.io/badge/FastAPI-Backend-teal)
![Node.js](https://img.shields.io/badge/Node.js-Gateway-brightgreen)
![VectorDB](https://img.shields.io/badge/VectorDB-Embeddings-purple)
![Status](https://img.shields.io/badge/Status-Production%20Ready-success)

---

## 📌 Project Overview

This is a **complete A–Z production-grade Kubernetes project** built on **GCP VMs (without GKE)**.  
It demonstrates how to design, build, secure, and expose an **LLM-style application** using:

- Multi-master Kubernetes (kubeadm)
- HAProxy as external TCP load balancer
- NGINX Ingress Controller (NodePort – bare metal)
- cert-manager + Let’s Encrypt (HTTP-01)
- FastAPI (LLM backend)
- Node.js (API Gateway)
- Frontend UI
- Vector Database (for embeddings & semantic search)

This project reflects **real enterprise / on‑prem Kubernetes architecture**, not shortcuts.

---

## 🏗️ Project Architecture (End-to-End)

```
User / Browser
      |
      | https://llm.techwithdiwana.com
      |
[ GCP Static Public IP ]
      |
[ HAProxy VM ]
  - TCP :80  → cert-manager HTTP-01
  - TCP :443 → Application traffic
      |
[ NGINX Ingress Controller (NodePort) ]
      |
[ Kubernetes Services ]
      |
[ Pods ]
   ├─ Frontend
   ├─ Node.js Gateway
   ├─ FastAPI (LLM Backend)
   └─ Vector DB (Embeddings / Context Store)
```

---

## 🧠 LLM + Vector Database Flow

1. User sends query from Frontend
2. Request reaches Node.js Gateway
3. Gateway forwards to FastAPI
4. FastAPI:
   - Generates embeddings
   - Queries Vector DB (cosine similarity)
   - Fetches relevant context
5. Context + prompt processed by LLM logic
6. Response returned to user

👉 This makes the project **AI + DevOps combined**.

---

## PHASE 0 – SSH Key (Secure Access)

**Why:** Password-based login is insecure. SSH keys are industry standard.

```powershell
ssh-keygen -t ed25519 -f $HOME\.ssh\gcp-techwithdiwana
cat $HOME\.ssh\gcp-techwithdiwana.pub
ssh -i $HOME\.ssh\gcp-techwithdiwana ubuntu@<VM_PUBLIC_IP>
```

---

## PHASE 1 – VM Creation (5 VMs)

### Topology

| VM Name      | Role          |
|--------------|---------------|
| haproxy-1    | Load balancer |
| k8s-master-1 | Control plane |
| k8s-master-2 | Control plane |
| k8s-worker-1 | Worker        |
| k8s-worker-2 | Worker        |

**Why:** Removes single point of failure and mimics real DC setups.

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

## PHASE 2 – Firewall

**Why:** Kubernetes API, Ingress, NodePort, and app traffic must be allowed.

```powershell
gcloud compute firewall-rules create allow-k8s-all `
  --allow="tcp:22,tcp:80,tcp:443,tcp:6443,tcp:30000-32767" `
  --source-ranges=0.0.0.0/0 `
  --target-tags=k8s-node
```

---

## PHASE 3 – Linux Prep (ALL K8s Nodes)

**Why:** Kubernetes requires swap off + proper kernel networking.

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

## PHASE 4 – containerd Runtime

**Why:** Docker shim is deprecated; containerd is production runtime.

```bash
apt update
apt install -y containerd
mkdir -p /etc/containerd
containerd config default >/etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd
```

---

## PHASE 5 – Kubernetes Binaries

```bash
apt install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key |
gpg --dearmor -o /etc/apt/keyrings/kubernetes.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" >/etc/apt/sources.list.d/kubernetes.list

apt update
apt install -y kubeadm kubelet kubectl
apt-mark hold kubeadm kubelet kubectl
```

---

## PHASE 6 – HAProxy (Kubernetes API)

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

---

## 🔥 EXTRA – HAProxy for Ingress + SSL (CRITICAL)

```cfg
############################################
# Ingress HTTPS (Application Traffic)
############################################
frontend ingress_https
    bind *:443
    mode tcp
    default_backend ingress_https_back

backend ingress_https_back
    mode tcp
    balance roundrobin
    server worker1 10.160.0.63:31441 check
    server worker2 10.160.15.192:31441 check

############################################
# Ingress HTTP (for cert-manager HTTP-01)
############################################
frontend ingress_http
    bind *:80
    mode tcp
    default_backend ingress_http_back

backend ingress_http_back
    mode tcp
    balance roundrobin
    server worker1 10.160.0.63:32392 check
    server worker2 10.160.15.192:32392 check
```

---

## PHASE 7 – kubeadm init

```bash
kubeadm init   --control-plane-endpoint "<HAPROXY_PRIVATE_IP>:6443"   --pod-network-cidr=10.244.0.0/16   --upload-certs
```

---

## PHASE 8 – Join Nodes

```bash
kubeadm join <HAPROXY_PRIVATE_IP>:6443   --token <TOKEN>   --discovery-token-ca-cert-hash sha256:<HASH>
```

---

## PHASE 9 – CNI (Flannel)

```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

---

## PHASE 10 – Ingress Controller

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.1/deploy/static/provider/baremetal/deploy.yaml
```

---

## PHASE 11 – cert-manager

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

---

## 🔥 EXTRA – ClusterIssuer

**File:** letsencrypt-prod.yaml

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: techwithdiwana@gmail.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

```bash
kubectl apply -f letsencrypt-prod.yaml
```

---

## PHASE 12 – Build Application Images

```bash
docker build -t techwithdiwana/llm-fastapi:v1 .
docker build -t techwithdiwana/llm-node-gateway:v1 .
docker build -t techwithdiwana/llm-frontend:v1 .
```

---

## PHASE 13 – Deploy Application

```bash
kubectl apply -f k8s/
```

---

## PHASE 14 – DNS

```
llm.techwithdiwana.com → <STATIC_PUBLIC_IP_OF_HA_PROXY>
```

---

## ✅ Final Validation

```bash
kubectl get pods -A
kubectl get ingress -n techwithdiwana-llm-prod
kubectl get certificate -n techwithdiwana-llm-prod
```

---

## 👨‍💻 Author

**Diwana Kumar**  
YouTube: Tech With Diwana

---

✅ A–Z steps included  
✅ No command removed  
✅ Production-grade explanations  
