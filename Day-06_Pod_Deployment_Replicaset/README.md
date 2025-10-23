# 🚀 Kubernetes Day 6: Pods, ReplicaSets & Deployments
> *A Complete Hands-On Guide — From Cluster Setup to Production-Ready Deployments*

<p align="center">
  <img src="https://img.shields.io/badge/Kubernetes-1.29-blue?style=for-the-badge&logo=kubernetes" />
  <img src="https://img.shields.io/badge/Platform-Kind%20Cluster-blue?style=for-the-badge&logo=docker" />
  <img src="https://img.shields.io/badge/Level-Beginner%20to%20Advanced-success?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Author-Tech%20With%20Diwana-red?style=for-the-badge&logo=youtube" />
</p>

## 🧠 Overview
In this **Day 6** session, you’ll master three core Kubernetes building blocks:
1. **Pods** — The smallest deployable unit in Kubernetes.
2. **ReplicaSets** — Ensures the desired number of Pods are always running.
3. **Deployments** — Simplifies app rollout, scaling, and rollback management.

---
## ⚙️ Prerequisites
| Tool | Version | Required |
|------|----------|-----------|
| 🐳 Docker Desktop | Latest | ✅ |
| 🧱 Kind | v0.23+ | ✅ |
| 💻 Kubectl | v1.29+ | ✅ |
| 🪟 OS | Windows 10/11 / WSL2 | ✅ |

---
## 🏗️ Step 1: Setup Kind Cluster
Create `kind-config.yaml` and run:
```bash
kind create cluster --name day6-twd-cluster --config kind-config.yaml
kubectl get nodes
kubectl cluster-info
```
---
## 🌱 Step 2: Create Namespace
```bash
kubectl create ns day6
```
---
## 🧩 Step 3: Pods
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  namespace: day6
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    ports:
    - containerPort: 80
```
---
## 🧩 Step 4: ReplicaSets
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: rs-nginx
  namespace: day6
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
```
---
## 🧩 Step 5: Deployments
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy-nginx
  namespace: day6
spec:
  replicas: 3
  selector:
    matchLabels:
      app: d-nginx
  template:
    metadata:
      labels:
        app: d-nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
```
---
## 🌐 Step 6: Expose Deployment
```bash
kubectl -n day6 expose deployment deploy-nginx --type=NodePort --port=80
kubectl -n day6 get svc
```
Open: `http://localhost:30080`
---
## ⚡ Step 7: Scaling & Updating
```bash
kubectl -n day6 scale deployment deploy-nginx --replicas=5
kubectl -n day6 set image deployment/deploy-nginx nginx=nginx:1.27
kubectl -n day6 rollout status deployment deploy-nginx
kubectl -n day6 rollout undo deployment deploy-nginx
```
---
## 🧹 Step 8: Cleanup
```bash
kubectl delete ns day6
```
---
<p align="center">
  <b>💻 Follow the Full Series →</b><br>
  <a href="https://www.youtube.com/playlist?list=PL9YnOxYKGRNM977HPsLGTdpXbyI6adgC2">
    <img src="https://img.shields.io/badge/YouTube%20Series-Tech%20With%20Diwana-red?style=for-the-badge&logo=youtube" />
  </a>
</p>
