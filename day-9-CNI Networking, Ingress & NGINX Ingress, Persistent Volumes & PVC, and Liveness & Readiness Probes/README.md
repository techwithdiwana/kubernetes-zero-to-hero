
# Kubernetes Zero to Hero — **Day‑9** (Minikube Edition)

<p align="center">
  <img alt="Kubernetes" src="https://img.shields.io/badge/Kubernetes-Day--9-blue">
  <img alt="Minikube" src="https://img.shields.io/badge/Minikube-Ready-success">
  <img alt="NGINX Ingress" src="https://img.shields.io/badge/Ingress-NGINX-informational">
  <img alt="Storage" src="https://img.shields.io/badge/Storage-PV%2FPVC-important">
  <img alt="Probes" src="https://img.shields.io/badge/Health-Liveness%20%7C%20Readiness-brightgreen">
  <img alt="Workflow" src="https://img.shields.io/badge/Workflow-DryRun%E2%86%92Review%E2%86%92Apply-lightgrey">
  <img alt="License" src="https://img.shields.io/badge/License-MIT-lightgrey">
</p>

> **World‑class, beginner‑to‑pro guide** for Day‑9: Cluster Networking (CNI), Ingress & NGINX Ingress,
> Persistent Volumes & PVC, and Liveness/Readiness Probes — fully **Minikube‑based** with **dry‑run‑first** workflow.
> This repo includes ready‑to‑use manifests, scripts, and troubleshooting.

---

## 🔥 What You’ll Learn
- **CNI basics** — How Pods get IPs and talk across nodes (flat, routable Pod network; no NAT inside cluster).
- **Ingress (NGINX)** — One external endpoint routing to multiple services by host/path.
- **Persistent storage** — PV/PVC for data that survives Pod restarts (dynamic provisioning in Minikube).
- **Self‑healing** — Liveness & Readiness probes (restart when unhealthy; serve only when ready).
- **Pro workflow** — Always **dry‑run → review YAML → apply** for safe, reproducible configs.

---

## 📁 Repository Structure

```
📦 day-9-minikube
├─ manifests/
│  ├─ 01-networking/                # (read-only notes; observe CNI state)
│  ├─ 02-ingress/
│  │  ├─ app1.yaml                  # generated via dry-run (nginx Deployment)
│  │  ├─ app1-svc.yaml              # generated via dry-run (ClusterIP Service)
│  │  ├─ app2.yaml                  # generated via dry-run (httpd Deployment)
│  │  ├─ app2-svc.yaml              # generated via dry-run (ClusterIP Service)
│  │  └─ ingress-demo.yaml          # generated via dry-run (2 path rules)
│  ├─ 03-storage/
│  │  ├─ pv-pvc-demo.yaml           # your List manifest (PV+PVC) produced by dry-run command
│  │  └─ pod-with-pvc.yaml          # base pod + added mounts to use PVC
│  └─ 04-probes/
│     └─ probes-demo.yaml           # base pod + liveness & readiness probes
├─ scripts/
│  ├─ 00-minikube-setup.ps1         # Windows helper
│  ├─ 00-minikube-setup.sh          # Linux/macOS helper
│  └─ 10-cleanup.sh                 # Clean everything
├─ docs/
│  ├─ HOSTS.md                      # Hostname mapping guide
│  └─ TROUBLESHOOTING.md            # Common issues & fixes
├─ .gitignore
├─ LICENSE
└─ README.md                        # this file
```

> **Note:** The manifests provided here mirror what you would get from the **dry‑run commands** below. For teaching,
> you’ll run the dry‑run first, review, then apply. We include the final YAMLs so viewers can follow offline.

---

## ✅ Prerequisites

- **Minikube** + **kubectl** installed
- Windows 10/11 (PowerShell) or macOS/Linux terminal

Quick start:
```bash
minikube start --cpus=4 --memory=6g
minikube addons enable ingress
minikube addons enable storage-provisioner
```

---

## 🌐 1) Cluster Networking (CNI) — *Understand the Backbone*

**Why it matters (2‑line explainer):** Kubernetes relies on **CNI plugins** to provide Pod IPs and flat routing across nodes.
If CNI fails, Pod‑to‑Pod communication breaks and most workloads fail.

**Observe networking:**

```bash
kubectl get nodes -o wide
kubectl get pods -A -o wide
kubectl describe node $(kubectl get nodes -o jsonpath='{.items[0].metadata.name}') | grep -i PodCIDR
```

Look for:
- Every **Pod has a unique IP** within the **PodCIDR**.
- Pods can talk across nodes without NAT inside the cluster.

> In Minikube, CNI is preconfigured; this section is **observe & verify**.

---

## 🌍 2) Ingress & NGINX Ingress — *One Door, Many Apps*

**Why it matters:** Instead of exposing each microservice with separate NodePorts, use **Ingress** for smarter routing on a single endpoint
(by path or host). **NGINX Ingress** is a production‑grade controller.

### 2.1 Enable Ingress (Minikube addon)

```bash
minikube addons enable ingress
kubectl -n ingress-nginx get pods
```

> Wait until the controller is **Ready**.

### 2.2 Create Two Sample Apps — **Dry‑Run → Apply**

```bash
# Deployments (dry-run to files)
kubectl create deployment app1 --image=nginx --dry-run=client -o yaml > manifests/02-ingress/app1.yaml
kubectl create deployment app2 --image=httpd --dry-run=client -o yaml > manifests/02-ingress/app2.yaml

# Apply deployments
kubectl apply -f manifests/02-ingress/app1.yaml
kubectl apply -f manifests/02-ingress/app2.yaml

# Services (dry-run to files)
kubectl expose deployment app1 --port=80 --dry-run=client -o yaml > manifests/02-ingress/app1-svc.yaml
kubectl expose deployment app2 --port=80 --dry-run=client -o yaml > manifests/02-ingress/app2-svc.yaml

# Apply services
kubectl apply -f manifests/02-ingress/app1-svc.yaml
kubectl apply -f manifests/02-ingress/app2-svc.yaml
```

### 2.3 Create Ingress Rule — **Dry‑Run → Apply**

```bash
kubectl create ingress demo-ingress   --rule="myapp.local/app1=app1:80"   --rule="myapp.local/app2=app2:80"   --class=nginx   --dry-run=client -o yaml > manifests/02-ingress/ingress-demo.yaml

kubectl apply -f manifests/02-ingress/ingress-demo.yaml
```

### 2.4 Access in Browser

Edit hosts (Windows path; similar on macOS/Linux): see `docs/HOSTS.md`.

```
127.0.0.1 myapp.local
```

Open:
- http://myapp.local/app1  → **nginx**
- http://myapp.local/app2  → **httpd**

> **Why this is pro:** One domain → many services with clean path routing.

---

## 💾 3) Persistent Volumes (PV) & Persistent Volume Claims (PVC) — *Data that Survives*

**Why it matters:** Pods are ephemeral; storage must persist across restarts. **PV** is the storage resource (disk/NFS/cloud),
**PVC** is the app’s request for storage (size/access‑mode).

### 3.1 Generate Your Combined PV+PVC — **Dry‑Run → File** (Your command)

```bash
kubectl create -f - --dry-run=client -o yaml > manifests/03-storage/pv-pvc-demo.yaml <<'EOF'
apiVersion: v1
kind: List
items:
  - apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: my-pv
    spec:
      capacity:
        storage: 1Gi
      accessModes:
        - ReadWriteOnce
      hostPath:
        path: /mnt/data
  - apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: my-pvc
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 500Mi
EOF
```

Apply and verify binding:

```bash
kubectl apply -f manifests/03-storage/pv-pvc-demo.yaml
kubectl get pv,pvc
```

> In Minikube, `storage-provisioner` supports dynamic provisioning. We include a PV here to demonstrate both explicit PV and PVC.

### 3.2 Use PVC in a Pod — **Dry‑Run → Edit → Apply**

```bash
kubectl run pod-with-pvc --image=nginx --port=80 --dry-run=client -o yaml > manifests/03-storage/pod-with-pvc.yaml
```

Then edit `manifests/03-storage/pod-with-pvc.yaml` and add mounts (already included in this repo’s file):

```yaml
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    volumeMounts:
    - mountPath: "/usr/share/nginx/html"
      name: my-storage
  volumes:
  - name: my-storage
    persistentVolumeClaim:
      claimName: my-pvc
```

Apply and test persistence:

```bash
kubectl apply -f manifests/03-storage/pod-with-pvc.yaml
kubectl exec -it pod-with-pvc -- bash -lc 'echo "Persistent Data Test" > /usr/share/nginx/html/index.html'
kubectl delete pod pod-with-pvc
kubectl apply -f manifests/03-storage/pod-with-pvc.yaml
kubectl exec -it pod-with-pvc -- cat /usr/share/nginx/html/index.html
# Expected: Persistent Data Test
```

---

## ❤️ 4) Liveness & Readiness Probes — *Self‑Healing Apps*

**Why it matters:** **Liveness** restarts hung/broken containers automatically; **Readiness** ensures only healthy Pods receive traffic.

### 4.1 Generate Pod with Probes — **Dry‑Run → Edit → Apply**

```bash
kubectl run probe-demo --image=nginx --port=80 --dry-run=client -o yaml > manifests/04-probes/probes-demo.yaml
```

Edit `manifests/04-probes/probes-demo.yaml` (already included in repo):

```yaml
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 3
      periodSeconds: 3
```

Apply and observe:

```bash
kubectl apply -f manifests/04-probes/probes-demo.yaml
kubectl describe pod probe-demo | sed -n '1,120p'
```

### 4.2 Simulate Failure → Watch Auto‑Heal

```bash
kubectl exec -it probe-demo -- rm -rf /usr/share/nginx/html
kubectl get pod probe-demo -w
```

The Pod restarts as liveness fails — **auto‑healing confirmed**.

---

## 🧪 Verification Checklist

- `kubectl get pods -A -o wide` → Pod IPs visible; CNI OK.
- `http://myapp.local/app1` & `/app2` → routed correctly; Ingress OK.
- `kubectl get pv,pvc` → **Bound**; storage OK.
- `probe-demo` restarts after failure; probes OK.

---

## 🧰 Helpful Scripts

- Windows PowerShell: `scripts/00-minikube-setup.ps1`
- Bash: `scripts/00-minikube-setup.sh`
- Cleanup: `scripts/10-cleanup.sh`

```powershell
# scripts/00-minikube-setup.ps1
minikube start --cpus=4 --memory=6g
minikube addons enable ingress
minikube addons enable storage-provisioner
Write-Host "Minikube + Ingress + Storage ready."
```

```bash
# scripts/00-minikube-setup.sh
#!/usr/bin/env bash
set -euo pipefail
minikube start --cpus=4 --memory=6g
minikube addons enable ingress
minikube addons enable storage-provisioner
echo "Minikube + Ingress + Storage ready."
```

```bash
# scripts/10-cleanup.sh
#!/usr/bin/env bash
set -euo pipefail
kubectl delete ingress demo-ingress --ignore-not-found
kubectl delete svc app1 app2 --ignore-not-found
kubectl delete deploy app1 app2 --ignore-not-found
kubectl delete -f manifests/03-storage/pod-with-pvc.yaml --ignore-not-found
kubectl delete -f manifests/03-storage/pv-pvc-demo.yaml --ignore-not-found
kubectl delete -f manifests/04-probes/probes-demo.yaml --ignore-not-found
```

---

## 🩺 Troubleshooting

See `docs/TROUBLESHOOTING.md`.

Common quick checks:
- Ingress 404 → controller Ready? Ingress rules applied? hosts file set?
- PVC Pending → `storage-provisioner` running?
- Probes failing → correct path/port; tune `initialDelaySeconds`.

---

## 📖 Hosts Mapping

See `docs/HOSTS.md` for host entries (Windows/macOS/Linux).

---

## 🧪 CI Ideas (Optional)

- GitHub Actions job to run `kubectl apply --dry-run=client -f` and basic linting on PRs.
- Add `yamllint` / `kubeval` for schema checks.

---

## 📝 License

MIT — free to use and adapt for your channel & community.
