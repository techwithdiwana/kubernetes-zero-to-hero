
<p align="center">
  <img src="https://img.shields.io/badge/Kubernetes-3178C6?style=for-the-badge&logo=kubernetes&logoColor=white" />
  <img src="https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white" />
  <img src="https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white" />
  <img src="https://img.shields.io/badge/Minikube-FFCB2B?style=for-the-badge&logo=kubernetes&logoColor=black" />
  <img src="https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=helm&logoColor=white" />
  <img src="https://img.shields.io/badge/Ingress-NGINX%20Ingress-009639?style=for-the-badge&logo=nginx&logoColor=white" />
  <img src="https://img.shields.io/badge/DevOps%20Project-Ready-brightgreen?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Tech%20With%20Diwana-Special%20Edition-blue?style=for-the-badge" />
</p>

# Day 12 – Prometheus & Grafana on Minikube (with Ingress)  

This project is for your **Day 12 YouTube video**.  
You will:  

1. Run a **sample frontend app** using your existing Docker image: `techwithdiwana/frontend:v1`.  
2. Install **kube-prometheus-stack** (Prometheus + Grafana + Alertmanager, node-exporter, kube-state-metrics).  
3. Expose **Sample App, Grafana, and Prometheus** via **NGINX Ingress**.  
4. Build a **professional dashboard** in Grafana showing **node-level** and **pod-level** metrics.  

Everything is tested for a **local Minikube cluster** (Windows + VirtualBox is fine).  

---

## 1. Prerequisites

- Windows 11
- **Minikube** (with VirtualBox / Docker driver)
- **kubectl**
- **Helm 3**
- Internet access (to pull Helm charts and Docker images)

### 1.1 Start Minikube

Give Minikube enough resources so Prometheus, Grafana, and your app can run smoothly:

```bash
minikube start --cpus=2 --memory=4096
```

Enable **Ingress** and **metrics-server**:

```bash
minikube addons enable ingress
minikube addons enable metrics-server
```

Verify:

```bash
kubectl get pods -n kube-system
```

You should see an `ingress-nginx-controller` pod in `Running` state.

---

## 2. Project Structure

```text
day12-prometheus-grafana/
├── README.md
└── k8s/
    ├── monitoring-namespace.yaml
    ├── sample-app-namespace.yaml
    ├── sample-app-deployment.yaml
    ├── sample-app-service.yaml
    ├── sample-app-ingress.yaml
    ├── grafana-ingress.yaml
    └── prometheus-ingress.yaml
```

You only have to run `kubectl apply -f ...` and a Helm command – everything else is ready.

---

## 3. Namespaces

Create namespaces for monitoring and for the demo app:

```bash
kubectl apply -f k8s/monitoring-namespace.yaml
kubectl apply -f k8s/sample-app-namespace.yaml
```

Check:

```bash
kubectl get ns
```

You should see `monitoring` and `sample-app`.

---

## 4. Install kube-prometheus-stack (Prometheus + Grafana)

We use the official **prometheus-community/kube-prometheus-stack** Helm chart.  
This is industry standard and comes with **ready-made dashboards and alerts** for Kubernetes. 

### 4.1 Add Helm repo

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### 4.2 Install the stack

We use the release name **`kps`** (short, so service names are clean):

```bash
helm install kps prometheus-community/kube-prometheus-stack   --namespace monitoring
```

Wait until all pods are `Running` or `Completed`:

```bash
kubectl get pods -n monitoring
```

You should see pods for:
- `kps-kube-prometheus-stack-grafana`
- `kps-kube-prometheus-stack-prometheus`
- `kube-state-metrics`
- `prometheus-node-exporter`
- `alertmanager`, etc.

---

## 5. Deploy the Sample Frontend App

We use **your image** directly: `techwithdiwana/frontend:v1`.

Apply the YAMLs:

```bash
kubectl apply -f k8s/sample-app-deployment.yaml
kubectl apply -f k8s/sample-app-service.yaml
kubectl apply -f k8s/sample-app-ingress.yaml
```

Check:

```bash
kubectl get pods -n sample-app
kubectl get svc -n sample-app
kubectl get ingress -n sample-app
```

---

## 6. Configure Ingress for App, Grafana, and Prometheus

### 6.1 Hostnames

We will expose:

- **Sample app** – `http://app.local`
- **Grafana** – `http://grafana.local`
- **Prometheus** – `http://prometheus.local`

First, get Minikube IP:

```bash
minikube ip
```

Suppose you get something like `192.168.59.100`.

Edit your **hosts file** (as Administrator) on Windows:

```text
C:\Windows\System32\drivers\etc\hosts
```

Add lines:

```text
192.168.59.100  app.local
192.168.59.100  grafana.local
192.168.59.100  prometheus.local
```

Save and close.

### 6.2 Ingress for Grafana and Prometheus

Apply:

```bash
kubectl apply -f k8s/grafana-ingress.yaml
kubectl apply -f k8s/prometheus-ingress.yaml
```

Check:

```bash
kubectl get ingress -n monitoring
```

---

## 7. Test URLs in Browser

Now open these URLs in your browser:

- **Sample app:** http://app.local
- **Grafana UI:** http://grafana.local
- **Prometheus UI:** http://prometheus.local

### 7.1 Get Grafana admin password

Grafana credentials are stored in a secret created by the Helm chart.

```bash
kubectl get secret kps-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d
echo
```

Username is usually `admin`. Use the decoded password.

Login at http://grafana.local

Prometheus at http://prometheus.local does not require login by default.

---

## 8. Build a Professional Dashboard (Node + Pod Level)

The kube-prometheus-stack already ships with **many dashboards**.  
But for your video, create **one custom dashboard** and show how to use PromQL.

### 8.1 Node-level metrics (CPU & Memory)

In Grafana:

1. Go to **Dashboards → New → New Dashboard → Add new panel**.

#### Panel 1 – Node CPU Usage (%)

**Query (PromQL):**

```promql
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

- Visualization: **Time series**
- Legend: `{{instance}}`
- Title: `Node CPU Usage %`

This shows how busy each node is.

#### Panel 2 – Node Memory Usage (%)

```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

- Legend: `{{instance}}`
- Title: `Node Memory Usage %`

---

### 8.2 Pod-level metrics (Your Sample App)

We will focus on the namespace `sample-app` and your app pods.

#### Panel 3 – App Pod CPU (milli-cores)

```promql
sum by (pod) (
  rate(
    container_cpu_usage_seconds_total{
      namespace="sample-app",
      pod=~"twd-frontend.*",
      container!="POD"
    }[2m]
  )
) * 1000


```

- Unit: `millicores (m)`
- Title: `App Pod CPU (m)`

#### Panel 4 – App Pod Memory (MiB)

```promql
sum by(pod) (
  container_memory_usage_bytes{
    namespace="sample-app",
   pod=~"twd-frontend.*"
  }
) / 1024 / 1024


### Panel 5 – Pod Restarts (per pod)
```
PromQL (current restart count):
sum by (pod) (
  kube_pod_container_status_restarts_total{
    namespace="sample-app",
    pod=~"twd-frontend.*"
  }
)

```

- Unit: `MiB`
- Title: `App Pod Memory (MiB)`

---

### 8.3 Save Dashboard

- Click **Save dashboard**, name it:  
  `K8s – Nodes & Sample App (Day 12)`
- Add a **folder** like `Tech With Diwana`.

This looks **very professional** and shows:

- Node CPU & memory for the whole cluster.
- Pod-level CPU & memory for your sample app.

---

## 9. Show Built‑in Dashboards (Bonus in Video)

Go to **Dashboards → Browse** and filter by tag `kubernetes`.  
Useful ones to showcase:

- **Kubernetes / Compute Resources / Cluster**
- **Kubernetes / Compute Resources / Namespace (Pods)**
- **Kubernetes / Nodes**

These dashboards come from kube-prometheus-stack and look very “enterprise”.

---

## 10. Useful Commands for the Video

### 10.1 Check all monitoring components

```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
kubectl get ingress -n monitoring
```

### 10.2 Describe Ingress

```bash
kubectl describe ingress grafana-ingress -n monitoring
kubectl describe ingress prometheus-ingress -n monitoring
```

### 10.3 Force pod restart (to show metrics changes)

```bash
kubectl delete pod -n sample-app -l app=twd-frontend
```

Pods will automatically restart from the Deployment, and you can show how metrics refresh in Grafana.

---

## 11. Clean Up

When you’re done:

```bash
helm uninstall kps -n monitoring

kubectl delete ns monitoring
kubectl delete ns sample-app

minikube delete
```

---

