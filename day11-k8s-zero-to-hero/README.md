# Kubernetes Zero to Hero — Day 11: Minikube + Helm + RBAC + HPA

<p align="center">
  <img src="https://img.shields.io/badge/Kubernetes-1.29-blue?logo=kubernetes&logoColor=white" />
  <img src="https://img.shields.io/badge/Minikube-Local%20Cluster-green?logo=kubernetes" />
  <img src="https://img.shields.io/badge/Helm-Chart%20Deployed-blue?logo=helm" />
  <img src="https://img.shields.io/badge/Autoscaling-HPA-orange?logo=kubernetes" />
  <img src="https://img.shields.io/badge/License-MIT-yellow" />
</p>

## 📌 Overview

This repo is **Day 11** of the *Kubernetes Zero to Hero* series by **Tech With Diwana**.

You will build a small **production-style setup** on a local Minikube cluster:

- Deploy a frontend app using **Helm + Ingress**
- Configure **RBAC** (ServiceAccount, Role, RoleBinding)
- Deploy a backend service with **CPU/Memory requests & limits**
- Configure **Horizontal Pod Autoscaler (HPA)** based on CPU
- Use a **load generator Job** to trigger real autoscaling
- Get a **practical view of VPA** (Vertical Pod Autoscaler) usage

This README is written so **anyone can follow step‑by‑step on their own laptop**.

> ℹ️ VPA controllers are **not installed** in this demo because upstream manifests change often
> and VPA is rarely used in production compared to HPA. We keep a simple `vpa.yaml` as reference only.

---

## 🧰 Prerequisites

You need:

- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- `kubectl`
- Helm 3 (on Windows you can use: `choco install kubernetes-helm`)
- Docker (or another Minikube-supported driver)

### Start Minikube & enable addons

```bash
minikube start
minikube addons enable ingress
minikube addons enable metrics-server
```

**Why these addons?**

- **Ingress** → provides NGINX Ingress Controller so we can use `http://twd.local`.
- **metrics-server** → exposes CPU/Memory metrics used by **HPA** and `kubectl top`.

Create a namespace for all Day‑11 objects:

```bash
kubectl create namespace twd-apps
```

---

## 🧱 Architecture

```text
Frontend (Helm)
  └─ Ingress (twd.local)

Backend: resource-demo (Deployment + Service)
  └─ HPA (CPU based)
      └─ Load Generator Job (busybox → HTTP calls)

RBAC: read-pod-sa + Role + RoleBinding
```

---

## 📁 Folder Structure

```text
day11-k8s-zero-to-hero/
├─ frontend-app/                  # Helm chart for frontend
├─ k8s-manifests/
│  ├─ rbac.yaml                   # ServiceAccount + Role + RoleBinding
│  ├─ app-resources.yaml          # resource-demo Deployment
│  ├─ service-resource-demo.yaml  # ClusterIP Service for resource-demo
│  ├─ hpa.yaml                    # Horizontal Pod Autoscaler
│  ├─ load-generator.yaml         # Busybox-based load generator Job
│  └─ vpa.yaml                    # VPA object (reference only)
└─ README.md
```

To use this repo:

```bash
git clone <your-fork-url>
cd day11-k8s-zero-to-hero
```

---

# 🚀 Step‑by‑Step

Each step explains **why**, **how**, and **what you achieve**.

---

## 1️⃣ Deploy Frontend with Helm + Ingress

### Why?

Helm is the *package manager* for Kubernetes. Most real clusters use Helm charts to manage apps.
Here we use a simple chart called `frontend-app` that serves a frontend image and exposes it via Ingress.

The chart is already in `frontend-app/`. Key values are in `values.yaml`:

```yaml
image:
  repository: techwithdiwana/frontend
  tag: "v1"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: twd.local
      paths:
        - path: /
          pathType: Prefix
```

### Deploy

```bash
helm upgrade --install twd-frontend ./frontend-app   --namespace twd-apps --create-namespace
```

Check resources:

```bash
kubectl get pods -n twd-apps
kubectl get svc -n twd-apps
kubectl get ingress -n twd-apps
```

### Access via browser

Get Minikube IP:

```bash
minikube ip
```

Add this line in your hosts file (Windows: `C:\Windows\System32\drivers\etc\hosts`):

```text
<MINIKUBE_IP>  twd.local
```

Now open: **http://twd.local**

✅ **Result:** a running frontend app managed by Helm, exposed through Ingress with a friendly hostname.

---

## 2️⃣ RBAC: ServiceAccount + Role + RoleBinding

### Why?

By default, Pods should **not** run with cluster‑admin rights. RBAC lets us give each workload
only the permissions it needs. Here we create a ServiceAccount that can **only read pods**
in the `twd-apps` namespace.

### Apply RBAC manifest

```bash
kubectl apply -f k8s-manifests/rbac.yaml
```

This creates:

- `read-pod-sa` – ServiceAccount (identity for workloads)
- `pod-reader-role` – Role allowing `get`/`list` on pods
- `pod-reader-binding` – RoleBinding linking the SA to that Role

### Verify & test

```bash
kubectl get sa -n twd-apps
kubectl get role -n twd-apps
kubectl get rolebinding -n twd-apps
```

RBAC test:

```bash
kubectl auth can-i list pods   --as=system:serviceaccount:twd-apps:read-pod-sa   -n twd-apps
```

Expected: `yes`

✅ **Result:** a least‑privilege identity exactly like you would use in production.

---

## 3️⃣ Backend: `resource-demo` Deployment + Service

### Why?

We need a backend workload with **CPU/memory requests & limits** so that HPA can calculate
utilization percentages correctly.

### Apply Deployment & Service

```bash
kubectl apply -f k8s-manifests/app-resources.yaml
kubectl apply -f k8s-manifests/service-resource-demo.yaml
```

Check:

```bash
kubectl get deploy resource-demo -n twd-apps
kubectl get pods -l app=resource-demo -n twd-apps
kubectl get svc resource-demo -n twd-apps
kubectl top pods -n twd-apps
```

✅ **Result:** a backend deployment (`resource-demo`) reachable via a ClusterIP service
inside the cluster and reporting metrics via metrics‑server.

---

## 4️⃣ Horizontal Pod Autoscaler (HPA)

### Why?

HPA automatically adjusts the **number of Pods** based on metrics. In this lab we scale
`resource-demo` based on CPU utilization.

### Apply HPA

```bash
kubectl apply -f k8s-manifests/hpa.yaml
kubectl get hpa -n twd-apps
```

HPA configuration (from `hpa.yaml`):

- `scaleTargetRef` → `resource-demo` deployment
- `averageUtilization: 50` → target 50% of requested CPU
- `minReplicas: 1`, `maxReplicas: 5` → scaling range

✅ **Result:** a scaling policy ready to react when CPU usage increases.

---

## 5️⃣ Load Generator Job (Real CPU Load)

### Why a Job?

HPA does nothing until there is **real CPU pressure**. The `load-generator` Job simulates
traffic by repeatedly calling the `resource-demo` Service for ~3 minutes.

The Job uses a **busybox‑friendly shell loop** (no `SECONDS` variable) so it runs correctly
in all environments.

### Start the load

```bash
kubectl apply -f k8s-manifests/load-generator.yaml -n twd-apps
```

Watch HPA in one terminal:

```bash
kubectl get hpa -n twd-apps -w
```

Watch pods and metrics in another terminal:

```bash
kubectl get pods -n twd-apps
kubectl top pods -n twd-apps
```

You should see:

- HPA `TARGETS` CPU column exceeding `50%`
- Replica count increasing from `1` → `2` or `3`

The Job finishes automatically after about 180 seconds. You can also delete it manually:

```bash
kubectl delete -f k8s-manifests/load-generator.yaml -n twd-apps
```

✅ **Result:** you have observed **real autoscaling** driven by CPU metrics.

---

## 6️⃣ VPA – Honest Production Perspective

Vertical Pod Autoscaler (VPA) adjusts **CPU/memory requests** of Pods instead of changing
replica count. It is powerful but also more disruptive because it may evict Pods to apply
new resource values.

For this repo we keep things practical:

> **In real production, most companies prefer HPA over VPA.  
> VPA is NOT widely used because it evicts pods to update resources, causing risk of downtime and conflicts with HPA.**

The file `k8s-manifests/vpa.yaml` is provided only as a reference object targeting
`resource-demo` for learners who want to experiment in a cluster where VPA controllers
are already installed.

---

## 7️⃣ Verification Checklist

Run:

```bash
kubectl get pods -n twd-apps
kubectl get deploy -n twd-apps
kubectl get svc -n twd-apps
kubectl get ingress -n twd-apps
kubectl get hpa -n twd-apps
kubectl top pods -n twd-apps
```

You should see:

- Frontend deployment via Helm and Ingress.
- Backend `resource-demo` deployment & service.
- HPA with current/desired replicas.
- Pod metrics via `kubectl top`.

---

## 8️⃣ Cleanup

```bash
helm uninstall twd-frontend -n twd-apps || true
kubectl delete -f k8s-manifests/hpa.yaml -n twd-apps || true
kubectl delete -f k8s-manifests/load-generator.yaml -n twd-apps || true
kubectl delete -f k8s-manifests/service-resource-demo.yaml -n twd-apps || true
kubectl delete -f k8s-manifests/app-resources.yaml -n twd-apps || true
kubectl delete -f k8s-manifests/rbac.yaml -n twd-apps || true
kubectl delete namespace twd-apps || true
```

---

## 📜 License

This project is licensed under the **MIT License**.

---

## ⭐ Author

**Tech With Diwana** — Kubernetes Zero to Hero Series
