# 🚀 Kubernetes Services (ClusterIP, NodePort, LoadBalancer) — Day-7 | Tech With Diwana

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.28%2B-326ce5?logo=kubernetes&logoColor=white)](#) [![Minikube](https://img.shields.io/badge/Minikube-VirtualBox-success?logo=virtualbox&logoColor=white)](#) [![Windows](https://img.shields.io/badge/Windows-10%2F11-blue?logo=windows)](#) [![License](https://img.shields.io/badge/License-MIT-green.svg)](#license) [![YouTube](https://img.shields.io/badge/Watch_on-YouTube-red?logo=youtube)](https://www.youtube.com/@TechWithDiwana) [![Views](https://komarev.com/ghpvc/?username=TechWithDiwana&label=Repo+Views&color=brightgreen)](#)

---

## 📖 **Overview**

This repository is part of **Kubernetes Zero to Hero** by **Tech With Diwana**.  
**Day-7** focuses on **Kubernetes Services** — the networking abstraction that gives your Pods a **stable identity (IP + DNS)** and a **reliable entrypoint** for traffic.

We’ll cover **theory** (what/why/how/types) and an **end‑to‑end practical** on **Minikube (VirtualBox driver)** with **dry‑run → YAML → apply → verify → access** for:
- **ClusterIP**
- **NodePort**
- **LoadBalancer**

---

## 🧠 **What is a Service in Kubernetes?**

Pods are **ephemeral**: when they restart, their **IPs change**. A **Service** solves this by providing:
- A **stable virtual IP (ClusterIP)** and **DNS name**.
- **Label‑selector based discovery** to target the right Pods.
- **Built‑in load balancing** across matching Pods.
- A clean **abstraction** so clients don’t depend on Pod IPs.

> **In short:** Pods change. **Services stay** — acting as the permanent door to your application.

---

## 💡 **Why do we use Services?**

- **Stable connectivity** to dynamic Pods.  
- **Expose applications** inside the cluster or to the outside world.  
- **Distribute traffic** (load balance) across replicas.  
- **Decouple networking** concerns from app code and Pod churn.

---

## 🧩 **Types of Services (with use‑cases)**

| **Type**       | **Scope**               | **What it does**                                              | **Typical use**                           |
|----------------|-------------------------|---------------------------------------------------------------|-------------------------------------------|
| **ClusterIP**  | Internal (in‑cluster)   | Gives a virtual IP/DNS reachable only inside the cluster      | Service‑to‑service (backend → DB)         |
| **NodePort**   | External (node IP:port) | Opens a fixed port on every node and forwards to the Service  | Local/demo access from your machine       |
| **LoadBalancer** | External (public IP)  | Allocates an external IP via LB (or Minikube tunnel locally)  | Internet‑facing apps / cloud‑like testing |

---

## 🧰 **Prerequisites**

- **Minikube** v1.35+ — <https://minikube.sigs.k8s.io/docs/start/>  
- **Oracle VirtualBox** v7+ — <https://www.virtualbox.org/wiki/Downloads>  
- **kubectl** v1.28+ — <https://kubernetes.io/docs/tasks/tools/>  
- **VS Code** (latest) — <https://code.visualstudio.com/>  
- **Windows PowerShell (Run as Administrator)** — required for `minikube tunnel`

> On Windows 10/11, ensure **Virtualization: Enabled** (Task Manager → CPU) and use **VirtualBox driver** for a routable Minikube VM IP.

---

## ⚙️ **Cluster Setup (VirtualBox)**

```bash
minikube start --driver=virtualbox --cpus=2 --memory=3072
kubectl get nodes -o wide
minikube ip   # note this IP for NodePort access
```

---

## 📁 **Folder Structure**

```
day7/
 ├─ README.md
 ├─ nginx-pod.yaml
 ├─ clusterip-svc.yaml
 ├─ nodeport-svc.yaml
 └─ loadbalancer-svc.yaml
```

---

# 💻 **Hands‑On: Dry‑Run → YAML → Apply → Verify → Access**

We’ll deploy **Nginx** and expose it via **ClusterIP**, **NodePort**, and **LoadBalancer**.

---

## 1) **Nginx Pod**

**Dry‑run → YAML**
```bash
kubectl run nginx-pod \
  --image=nginx:latest \
  --port=80 \
  --labels=app=nginx \
  --dry-run=client -o yaml > nginx-pod.yaml
```

**Generated YAML (`nginx-pod.yaml`)**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

**Apply & verify**
```bash
kubectl apply -f nginx-pod.yaml
kubectl get pods -o wide
```

**Concepts**
- `labels.app=nginx` → Services will target this Pod set.
- `containerPort: 80` → documentation/intent; Service maps `targetPort` here.

---

## 2) **ClusterIP Service** (internal only)

**Dry‑run → YAML**
```bash
kubectl expose pod nginx-pod \
  --port=80 \
  --target-port=80 \
  --name=nginx-clusterip \
  --dry-run=client -o yaml > clusterip-svc.yaml
```

**Generated YAML (`clusterip-svc.yaml`)**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-clusterip
spec:
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
```

**Apply & verify**
```bash
kubectl apply -f clusterip-svc.yaml
kubectl get svc nginx-clusterip
```

**Internal access test**
```bash
kubectl run testpod --image=busybox:latest -it -- /bin/sh
wget -qO- http://nginx-clusterip
exit
```

**Concepts**
- **ClusterIP** gives a virtual IP & DNS inside cluster only.  
- **selector** must match Pod labels; check endpoints with `kubectl get endpoints nginx-clusterip`.

---

## 3) **NodePort Service** (external via NodeIP:Port)

**Dry‑run → YAML**
```bash
kubectl expose pod nginx-pod \
  --type=NodePort \
  --port=80 \
  --target-port=80 \
  --name=nginx-nodeport \
  --dry-run=client -o yaml > nodeport-svc.yaml
```

> Optional: pin a fixed port (`30000–32767`) by editing YAML.

**Generated YAML (`nodeport-svc.yaml`)**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```

**Apply & verify**
```bash
kubectl apply -f nodeport-svc.yaml
kubectl get svc nginx-nodeport
minikube ip
```

**Access from browser**
```
http://<minikube-ip>:30080
```

**Concepts**
- **NodePort** opens `nodePort` on every node, forwarding to ClusterIP → Pod.  
- Great for local demos & quick external access.

---

## 4) **LoadBalancer Service** (external IP via tunnel)

**Dry‑run → YAML**
```bash
kubectl expose pod nginx-pod \
  --type=LoadBalancer \
  --port=80 \
  --target-port=80 \
  --name=nginx-loadbalancer \
  --dry-run=client -o yaml > loadbalancer-svc.yaml
```

**Generated YAML (`loadbalancer-svc.yaml`)**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
```

**Apply & allocate external IP**
```bash
kubectl apply -f loadbalancer-svc.yaml
kubectl get svc nginx-loadbalancer   # EXTERNAL-IP might be <pending>
```

**Start tunnel (Admin PowerShell)**  
> Keep this window open and allow firewall if prompted.
```bash
minikube tunnel
```

**Verify & access**
```bash
kubectl get svc nginx-loadbalancer
# then open in browser:
# http://<EXTERNAL-IP>
```

**Concepts**
- **LoadBalancer** requests a public IP; in Minikube this is emulated by `minikube tunnel`.  
- Mimics cloud behavior locally.

---

## 🔍 **Deep Dive: Service Anatomy**

- **metadata.name** — unique Service name.  
- **labels** — tags on objects (Pods) for grouping.  
- **selector** — which Pods this Service targets.  
- **ports.port** — Service port (stable, virtual).  
- **ports.targetPort** — container port on the Pod.  
- **nodePort** — external port on each node (NodePort type).  
- **type** — ClusterIP / NodePort / LoadBalancer.  
- **Endpoints** — resolved Pod IP:Port behind the Service.  
- **DNS** — `<svc>.<ns>.svc.cluster.local` for in‑cluster discovery.

---

## 🧯 **Troubleshooting**

- **Endpoints show `<none>`** → selector/labels mismatch.  
  ```bash
  kubectl get endpoints nginx-nodeport
  kubectl get pod nginx-pod -o jsonpath='{.metadata.labels}'
  kubectl label pod nginx-pod app=nginx --overwrite
  ```
- **Pod not ready**  
  ```bash
  kubectl describe pod nginx-pod
  kubectl logs nginx-pod --tail=50
  ```
- **NodePort not reachable** → verify `minikube ip`, check local firewall.  
- **LoadBalancer `<pending>`** → run `minikube tunnel` in **Administrator** shell.

---

## 🧹 **Cleanup**

```bash
kubectl delete svc nginx-clusterip nginx-nodeport nginx-loadbalancer
kubectl delete pod nginx-pod
minikube stop
# full reset:
minikube delete
```

---

## 📊 **Summary (Cheat‑Sheet)**

| **Type**        | **Access**           | **Best for**                      |
|-----------------|----------------------|-----------------------------------|
| ClusterIP       | In‑cluster only      | Service‑to‑service comms          |
| NodePort        | NodeIP:Port external | Local demos & quick external access |
| LoadBalancer    | Public IP            | Cloud‑like external exposure      |

---

## 🎥 **Watch the Episode**

👉 **YouTube:** <https://www.youtube.com/@TechWithDiwana>

---

## 👤 **Author**

**Tech With Diwana** — DevOps | Kubernetes | Cloud | CI/CD  
GitHub: <https://github.com/devopswithdiwana>

---

## 📄 **License**

MIT License — free to use, modify, and share.
