# 🧠 Kubernetes Zero to Hero — Day 4  
## 🚀 Multi-Node Kind Cluster Setup + App Deployment (Windows PowerShell Edition)

---

<p align="center">
  <img src="app/logo.png" alt="Tech With Diwana" width="120" />
</p>

<p align="center">
  <b>Welcome to Tech With Diwana!</b><br>
  Your Kind cluster is ready to use for deployment. 🌱
</p>

---

<p align="center">
  <img src="https://img.shields.io/badge/Kubernetes-v1.30-blue?logo=kubernetes&logoColor=white" />
  <img src="https://img.shields.io/badge/Kind-Cluster-orange?logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/Docker-Required-blue?logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/kubectl-CLI-lightgrey?logo=terminal&logoColor=white" />
  <img src="https://img.shields.io/badge/Windows-PowerShell-green?logo=powershell&logoColor=white" />
</p>

---

## 🎯 Objective
In this **Day 4** session of the *Kubernetes Zero to Hero* series, we’ll create a **multi-node Kind cluster** (2 masters + 2 workers) and deploy a small **NGINX-based web application** that displays:

> **Welcome to Tech With Diwana**  
> _Your Kind cluster is ready to use for deployment._

All steps are beginner-friendly and run directly from **PowerShell** on Windows.

---

## ⚙️ What You’ll Build
| Component | Description |
|------------|-------------|
| **Cluster Name** | `twd-cluster` |
| **Masters** | 2 |
| **Workers** | 2 |
| **App Name** | `twd-web` |
| **Service Type** | NodePort |
| **NodePort** | 30080 |
| **Access URL** | http://localhost:8080 or http://localhost:30080 |

---

## 🧰 Prerequisites (Already Covered in Earlier Sessions)
- Docker Desktop ✅ (from your Docker session)
- PowerShell 7+ ✅
- Internet Connection ✅

Install these **if not installed yet**:
```powershell
# Kind
choco install kind

# kubectl
choco install kubernetes-cli
```

Verify:
```powershell
kind version
kubectl version --client
```

---

## 🪜 STEP 1 — Create a Multi-Node Kind Cluster

### 1️⃣ Navigate to project directory
```powershell
cd twd-kind-demo-day4
```

### 2️⃣ Create the cluster
```powershell
kind create cluster --config .\kind\twd-kind-2cp-2w.yaml
```

📁 `kind/twd-kind-2cp-2w.yaml` defines:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: twd-cluster
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 30080
    protocol: TCP
- role: control-plane
- role: worker
- role: worker
```

### 3️⃣ Verify cluster status
```powershell
kubectl get nodes -o wide
```

✅ Output Example:
```
NAME                             STATUS   ROLES           AGE   VERSION
twd-cluster-control-plane        Ready    control-plane   1m    v1.30.x
twd-cluster-control-plane2       Ready    control-plane   1m    v1.30.x
twd-cluster-worker               Ready    <none>          1m    v1.30.x
twd-cluster-worker2              Ready    <none>          1m    v1.30.x
```

Congratulations 🎉 Your multi-node Kind cluster is running locally!

---

## 🪄 STEP 2 — Build and Load Your Application Image

### 1️⃣ Build Docker image
```powershell
docker build -t twd-web:1.0 .\app
```

### 2️⃣ Load image into Kind
```powershell
kind load docker-image twd-web:1.0 --name twd-cluster
```

This step makes your image available to all cluster nodes.

---

## 🚀 STEP 3 — Deploy Application on the Cluster

Apply the Kubernetes manifests:
```powershell
kubectl apply -f .\k8s\deployment-and-service.yaml
```

Verify deployment:
```powershell
kubectl get deploy,po,svc
kubectl rollout status deploy/twd-web
```

✅ Expected output:
```
deployment.apps/twd-web created
service/twd-web created
deployment "twd-web" successfully rolled out
```

---

## 🌐 STEP 4 — Access the Application

### Option A (Recommended)
Use **port-forwarding**:
```powershell
kubectl port-forward service/twd-web 8080:80
```
Then open → [http://localhost:8080](http://localhost:8080)

### Option B (NodePort)
Open directly in your browser:
```
http://localhost:30080
```

---

## 🖼️ Output Preview

<p align="center">
  <img src="app/logo.png" alt="TWD Logo" width="100" /><br>
  <b>Welcome to Tech With Diwana</b><br>
  Your Kind cluster is ready to use for deployment.
</p>

---

## 🧩 Project Structure

```
twd-kind-demo-day4/
│
├── app/
│   ├── Dockerfile
│   ├── index.html
│   └── logo.png
│
├── k8s/
│   └── deployment-and-service.yaml
│
├── kind/
│   └── twd-kind-2cp-2w.yaml
│
├── deploy.ps1
└── README.md
```

---

## 🧹 STEP 5 — Cleanup

To delete the cluster:
```powershell
kind delete cluster --name twd-cluster
```

To delete deployed resources only:
```powershell
kubectl delete -f .\k8s\deployment-and-service.yaml
```

---

## 📅 Series Progress
| Day | Topic | Status |
|-----|--------|---------|
| 🟢 Day 1 | Kubernetes Introduction | ✅ Completed |
| 🟢 Day 2 | Pods, ReplicaSets, Deployments | ✅ Completed |
| 🟢 Day 3 | Services & Networking | ✅ Completed |
| 🔵 **Day 4** | **Kind Cluster Setup + App Deployment** | 🚀 You Are Here |
| ⚪ Day 5 | Ingress & Load Balancing | ⏳ Coming Soon |

---

## 🧠 Learning Outcome
By completing this lab, you now understand:
- How to set up a **multi-node Kubernetes cluster using Kind**  
- How to **deploy and expose apps** using `kubectl`  
- How to access Kubernetes apps locally via **port-forward / NodePort**

---

## 💬 Author
**Tech With Diwana (TWD)**  
🎥 *Kubernetes Zero to Hero Series*  
📺 YouTube: [Tech With Diwana](https://youtube.com/@TechWithDiwana)  
🐙 GitHub: [github.com/devopswithdiwana](https://github.com/devopswithdiwana)
