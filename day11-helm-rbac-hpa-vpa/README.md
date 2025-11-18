# Tech With Diwana — Kubernetes Day 11 Lab

> **Helm + Ingress + RBAC + Resources + HPA + VPA (Production-Style Lab)**  
> Part of the _Kubernetes Zero to Hero_ series on **Tech With Diwana**.

---

## 🏷️ Project Badges

<p align="left">
  <a href="https://kubernetes.io/"><img src="https://img.shields.io/badge/Kubernetes-1.23%2B-326CE5?logo=kubernetes&logoColor=white" alt="K8s"></a>
  <a href="https://helm.sh/"><img src="https://img.shields.io/badge/Helm-3.x-0F1689?logo=helm&logoColor=white" alt="Helm"></a>
  <img src="https://img.shields.io/badge/Ingress-NGINX-009639?logo=nginx&logoColor=white" alt="Ingress NGINX">
  <img src="https://img.shields.io/badge/RBAC-Enabled-blueviolet" alt="RBAC">
  <img src="https://img.shields.io/badge/Autoscaling-HPA%20%26%20VPA-brightgreen" alt="Autoscaling">
  <img src="https://img.shields.io/badge/Namespace-twd--apps-orange" alt="Namespace twd-apps">
</p>

---

## 🎯 What You Will Learn

This lab demonstrates how to deploy a **real frontend application** to Kubernetes using **Helm** and secure & scale it using:

- ✅ **Helm** — package manager for Kubernetes  
- ✅ **Ingress** — domain-based HTTP routing (no `kubectl port-forward`)  
- ✅ **RBAC** — ServiceAccount, Role, RoleBinding  
- ✅ **Resource Requests & Limits** — CPU/Memory control  
- ✅ **HPA** — Horizontal Pod Autoscaler (scale out)  
- ✅ **VPA** — Vertical Pod Autoscaler (scale up resources)  
- ✅ **Dry runs** and **verification commands** for every object

---

## 📂 Repository Structure

```text
.
├── frontend-app/           # Helm chart (generated via `helm create`)
│   └── ...                 # templates/, values.yaml, Chart.yaml etc.
├── k8s-manifests/
│   ├── rbac.yaml           # ServiceAccount + Role + RoleBinding
│   ├── app-resources.yaml  # Deployment with CPU/Memory requests & limits
│   ├── hpa.yaml            # HorizontalPodAutoscaler for resource-demo
│   ├── vpa.yaml            # VerticalPodAutoscaler for resource-demo
└── README.md               # This file
```

> **Note:** The Helm chart folder `frontend-app/` is not auto-generated in this ZIP.  
> Create it locally with `helm create frontend-app` and then update `values.yaml` as described below.

---

## 🧩 Prerequisites

Before you start, make sure you have:

- A running **Kubernetes cluster** (kind, Minikube, Kubeadm, cloud cluster etc.)
- **kubectl** configured to talk to your cluster
- **Helm 3.x** installed
- **NGINX Ingress Controller** installed and running
- Optional but recommended: `metrics-server` installed for HPA/VPA metrics

Create the namespace once:

```bash
kubectl create namespace twd-apps
```

If it already exists, you will see an error which you can safely ignore.

---

## 🪙 Step 1 — Install Helm (if not already installed)

On Windows (Chocolatey):

```bash
choco install kubernetes-helm
helm version
```

On Linux/Mac use the official Helm docs or your package manager.

---

## 🚀 Step 2 — Create Helm Chart and Deploy Frontend

### 2.1 Create Helm Chart

```bash
helm create frontend-app
```

This generates:

- `templates/deployment.yaml` — Runs your Pods
- `templates/service.yaml` — Stable Service for networking
- `templates/ingress.yaml` — Ingress resource
- `values.yaml` — Central configuration file

### 2.2 Configure `values.yaml`

Open `frontend-app/values.yaml` and update:

```yaml
image:
  repository: techwithdiwana/frontend
  tag: "v1"
  pullPolicy: IfNotPresent

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: twd.local
      paths:
        - path: /
          pathType: Prefix
```

### 2.3 Dry Run (Preview Only)

```bash
helm upgrade --install twd-frontend ./frontend-app \
  --namespace twd-apps --create-namespace \
  --values frontend-app/values.yaml --dry-run
```

- ✅ Renders the final YAML  
- ❌ Does **not** create any resources yet

### 2.4 Real Deployment

```bash
helm upgrade --install twd-frontend ./frontend-app \
  --namespace twd-apps --create-namespace \
  --values frontend-app/values.yaml
```

### 2.5 Verify Helm Deployment

```bash
kubectl get pods -n twd-apps
kubectl get svc -n twd-apps
kubectl get ingress -n twd-apps
```

You should see a Pod for the frontend, a Service, and an Ingress with host `twd.local`.

### 2.6 Add Local Host Entry

> This simulates DNS in your local environment.

On Windows edit `C:\Windows\System32\drivers\etc\hosts`,  
on Linux/Mac edit `/etc/hosts` and add:

```text
127.0.0.1   twd.local
```

### 2.7 Access the App

Open your browser and go to:

```text
http://twd.local
```

You should see the **Tech With Diwana** frontend site.

---

## 🔐 Step 3 — RBAC: ServiceAccount + Role + RoleBinding

We now secure access using **RBAC**.

### 3.1 Concept

- **ServiceAccount** → Identity used by pods or scripts  
- **Role** → What actions are allowed in a namespace  
- **RoleBinding** → Connect a Role to a ServiceAccount

Real-world analogy:

- ID Card = ServiceAccount  
- Job Description = Role  
- HR Approval = RoleBinding

### 3.2 Dry Run

```bash
kubectl apply -f k8s-manifests/rbac.yaml --dry-run=client
```

### 3.3 Apply RBAC

```bash
kubectl apply -f k8s-manifests/rbac.yaml
```

### 3.4 Inspect RBAC Objects

```bash
kubectl get sa -n twd-apps
kubectl get roles -n twd-apps
kubectl get rolebindings -n twd-apps
```

### 3.5 Test RBAC Permissions

```bash
kubectl auth can-i list pods \
  --as=system:serviceaccount:twd-apps:read-pod-sa \
  -n twd-apps
```

Expected output:

```text
yes
```

Try a forbidden action:

```bash
kubectl auth can-i delete pods \
  --as=system:serviceaccount:twd-apps:read-pod-sa \
  -n twd-apps
```

Expected:

```text
no
```

---

## ⚙ Step 4 — Resource Requests & Limits

File: `k8s-manifests/app-resources.yaml`

### 4.1 Concept

- **Requests** = minimum CPU/Memory guaranteed for the container  
- **Limits** = maximum CPU/Memory the container is allowed to use  

Analogy:  
Reservation at a restaurant — your **request** guarantees a seat,  
but your **limit** is the space of that seat, you cannot occupy the whole hall.

### 4.2 Dry Run

```bash
kubectl apply -f k8s-manifests/app-resources.yaml --dry-run=client
```

### 4.3 Apply & Verify

```bash
kubectl apply -f k8s-manifests/app-resources.yaml
kubectl get pods -n twd-apps
kubectl top pods -n twd-apps
```

You should see the `resource-demo` Pod with resource usage.

---

## 📈 Step 5 — Horizontal Pod Autoscaler (HPA)

File: `k8s-manifests/hpa.yaml`

### 5.1 Concept

- **HPA** scales the **number of Pod replicas**  
- Uses metrics like CPU utilization  
- Helps handle traffic spikes automatically

### 5.2 Prerequisite

Make sure **metrics-server** is installed in your cluster.

### 5.3 Dry Run

```bash
kubectl apply -f k8s-manifests/hpa.yaml --dry-run=client
```

### 5.4 Apply & Check HPA

```bash
kubectl apply -f k8s-manifests/hpa.yaml
kubectl get hpa -n twd-apps
```

Under load, HPA will increase replicas of `resource-demo`.

---

## 📈 Step 6 — Vertical Pod Autoscaler (VPA)

File: `k8s-manifests/vpa.yaml`

### 6.1 Concept

- **VPA** adjusts CPU/Memory **requests and limits** for Pods automatically  
- Good for workloads with unpredictable resource usage  
- Often used together with HPA (carefully configured)

### 6.2 Install VPA Controller

```bash
kubectl apply -f https://github.com/kubernetes/autoscaler/releases/latest/download/vertical-pod-autoscaler.yaml
```

### 6.3 Dry Run

```bash
kubectl apply -f k8s-manifests/vpa.yaml --dry-run=client
```

### 6.4 Apply & Verify VPA

```bash
kubectl apply -f k8s-manifests/vpa.yaml
kubectl get vpa -n twd-apps
```

---

## ✅ Final Verification Checklist

Run these commands to confirm everything is deployed correctly:

```bash
kubectl get pods -n twd-apps
kubectl get svc -n twd-apps
kubectl get ingress -n twd-apps
kubectl get sa -n twd-apps
kubectl get roles -n twd-apps
kubectl get rolebindings -n twd-apps
kubectl get deploy -n twd-apps
kubectl get hpa -n twd-apps
kubectl get vpa -n twd-apps
```

You should see:

- Frontend deployment and pod(s) running  
- `twd-frontend` Service and Ingress  
- `read-pod-sa` ServiceAccount  
- `pod-reader-role` Role + RoleBinding  
- `resource-demo` deployment  
- `resource-hpa` and `resource-vpa` autoscalers

---

## 🧹 Cleanup

To remove all resources created in this lab:

```bash
helm uninstall twd-frontend -n twd-apps
kubectl delete -f k8s-manifests/hpa.yaml -n twd-apps
kubectl delete -f k8s-manifests/vpa.yaml -n twd-apps
kubectl delete -f k8s-manifests/app-resources.yaml -n twd-apps
kubectl delete -f k8s-manifests/rbac.yaml -n twd-apps
kubectl delete namespace twd-apps
```

---

## ❤️ Credits

This lab is part of the **Kubernetes Zero to Hero** series by  
**Tech With Diwana** — DevOps • Cloud • Kubernetes.

If you find this helpful:

- ⭐ Star this repository  
- 📺 Subscribe on YouTube: **Tech With Diwana**  
- 🔁 Share with your DevOps friends

Stay DevOps Strong! 💪
