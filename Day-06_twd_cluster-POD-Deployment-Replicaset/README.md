# 🚀 Kubernetes Day 6: Pods, ReplicaSets & Deployments
> *A Complete Hands-On Guide — From Cluster Setup to Production-Ready Deployments*

<p align="center">
  <img src="https://img.shields.io/badge/Kubernetes-1.29-blue?style=for-the-badge&logo=kubernetes" />
  <img src="https://img.shields.io/badge/Platform-Kind%20Cluster-blue?style=for-the-badge&logo=docker" />
  <img src="https://img.shields.io/badge/Level-Beginner%20to%20Advanced-success?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Author-Tech%20With%20Diwana-red?style=for-the-badge&logo=youtube" />
</p>

---

## 🧠 Overview

In this **Day 6** session, we’ll explore the most essential Kubernetes concepts:  
- **Pods** – Smallest deployable unit in Kubernetes.  
- **ReplicaSets** – Maintain the desired number of Pods.  
- **Deployments** – Manage rolling updates and rollbacks easily.

We'll start with a local Kind cluster setup and gradually move through each Kubernetes object with examples.  

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

We’ll create a lightweight Kind cluster to run Kubernetes locally.

### 📄 kind-config.yaml
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.29.2
  extraPortMappings:
  - containerPort: 30080
    hostPort: 30080
```

### ▶️ Create Cluster
```bash
kind create cluster --name twd-cluster --config kind-config.yaml
kubectl get nodes
kubectl cluster-info
```

✅ **Expected Output:**
```
NAME                      STATUS   ROLES           AGE   VERSION
twd-cluster-control-plane   Ready    control-plane   1m    v1.29.2
```

---

## 🌱 Step 2: Create Namespace
Namespaces are used to logically separate environments.

```bash
kubectl create ns day6
```

✅ **Output:**
```
namespace/day6 created
```

---

## 🧩 Step 3: Understanding Pods

### 🔍 What is a Pod?
A **Pod** is the smallest deployable unit in Kubernetes — it encapsulates one or more containers that share the same storage and network.

### 📄 nginx-pod.yaml
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

### ▶️ Create Pod
```bash
kubectl apply -f nginx-pod.yaml
```

### 🔎 Verify Pod
```bash
kubectl -n day6 get pods -o wide
```

✅ **Output:**
```
NAME         READY   STATUS    RESTARTS   AGE   IP          NODE
nginx-pod    1/1     Running   0          1m    10.244.0.5  twd-cluster-control-plane
```

---

## 🧩 Step 4: ReplicaSets

### 🔍 What is a ReplicaSet?
A **ReplicaSet** ensures a specified number of identical Pods are always running.  
If one fails, it automatically creates a new one.

### 📄 rs-nginx.yaml
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
        ports:
        - containerPort: 80
```

### ▶️ Apply ReplicaSet
```bash
kubectl apply -f rs-nginx.yaml
kubectl -n day6 get rs,pods
```

✅ **Output:**
```
NAME               DESIRED   CURRENT   READY   AGE
rs-nginx           3         3         3       1m
```

If you delete a Pod:
```bash
kubectl -n day6 delete pod <pod-name>
kubectl -n day6 get pods
```
🧠 ReplicaSet automatically recreates it!

---

## 🧩 Step 5: Deployments

### 🔍 What is a Deployment?
A **Deployment** is a higher-level abstraction over ReplicaSets.  
It manages updates, rollbacks, and scaling.

### 📄 deploy-nginx.yaml
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
        ports:
        - containerPort: 80
```

### ▶️ Apply Deployment
```bash
kubectl apply -f deploy-nginx.yaml
kubectl -n day6 get deploy,rs,pods
```

✅ **Output:**
```
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
deploy-nginx       3/3     3            3           1m
```

---

## 🌐 Step 6: Expose Deployment (NodePort Service)

### ▶️ Create Service
```bash
kubectl -n day6 expose deployment deploy-nginx --type=NodePort --port=80
kubectl -n day6 get svc
```

Open browser → `http://localhost:30080`  
✅ You should see the Nginx welcome page.

---

## ⚡ Step 7: Scaling & Rolling Updates

### 🧱 Scale Deployment
```bash
kubectl -n day6 scale deployment deploy-nginx --replicas=5
kubectl -n day6 get pods
```

### 🔄 Rolling Update
```bash
kubectl -n day6 set image deployment/deploy-nginx nginx=nginx:1.27
kubectl -n day6 rollout status deployment deploy-nginx
```

### 🔙 Rollback
```bash
kubectl -n day6 rollout undo deployment deploy-nginx
```

---

## 🧹 Step 8: Cleanup
```bash
kubectl delete ns day6
```

✅ Deletes all Pods, ReplicaSets, Deployments, and Services inside `day6` namespace.

---

## 🧭 Summary Table

| Resource | Description | Self-Healing | Rollback | Scaling |
|-----------|--------------|---------------|-----------|----------|
| Pod | Runs container(s) | ❌ | ❌ | ❌ |
| ReplicaSet | Maintains number of Pods | ✅ | ❌ | ✅ |
| Deployment | Manages ReplicaSets | ✅ | ✅ | ✅ |

---

## 📚 Full Workflow Recap

1️⃣ Setup Kind cluster using `kind-config.yaml`  
2️⃣ Create a new namespace `day6`  
3️⃣ Deploy a Pod (`nginx-pod.yaml`)  
4️⃣ Manage Pods using ReplicaSet (`rs-nginx.yaml`)  
5️⃣ Automate scaling and versioning with Deployment (`deploy-nginx.yaml`)  
6️⃣ Expose using NodePort service  
7️⃣ Scale, update, rollback, and clean up  

---

<p align="center">
  <b>💻 Follow the Full Series →</b><br>
  <a href="https://www.youtube.com/playlist?list=PL9YnOxYKGRNM977HPsLGTdpXbyI6adgC2">
    <img src="https://img.shields.io/badge/YouTube%20Series-Tech%20With%20Diwana-red?style=for-the-badge&logo=youtube" />
  </a>
</p>
