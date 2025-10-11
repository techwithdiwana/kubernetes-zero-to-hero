# 🚀 Day-2: Kubernetes Architecture  

![Kubernetes Architecture](./A_2D_digital_diagram_titled_"Kubernetes_Architectu.png)

<p align="center">
  <img src="https://img.shields.io/badge/Kubernetes-Architecture-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white" />
  <img src="https://img.shields.io/badge/Level-Intermediate-yellow?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Series-Tech%20With%20Diwana-blueviolet?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Edition-Educational-success?style=for-the-badge" />
</p>

---

## 🧠 What You’ll Learn Today
In **Day-2**, we dive into the **core architecture of Kubernetes (K8s)** — how all the internal components connect and communicate to run your containerized applications efficiently.

---

## 🏗️ Kubernetes Architecture Overview

Kubernetes has a **Master–Worker** design pattern that separates cluster control and workload execution.

### ⚙️ 1. Control Plane (Master Components)
Responsible for **managing and controlling** the entire Kubernetes cluster.

- **API Server:**  
  Acts as the front door for all Kubernetes requests (CLI, UI, or API calls).  
  Every command (`kubectl get pods`, etc.) passes through this component.

- **etcd:**  
  A **key–value database** that stores all cluster data — configuration, secrets, and states.

- **Controller Manager:**  
  Ensures the cluster stays in the **desired state** (like maintaining replicas and deployments).

- **Scheduler:**  
  Assigns Pods to nodes based on **resource availability** and scheduling policies.

---

### 🧩 2. Worker Nodes
Responsible for **running actual workloads (Pods/Containers)**.

- **Kubelet:**  
  Agent running on each node that communicates with the Control Plane.  
  It ensures Pods are running as expected.

- **Kube Proxy:**  
  Handles **networking** and forwards traffic between Services and Pods.

- **Container Runtime (Docker / containerd):**  
  The actual engine that runs containers inside Pods.

---

### 🌐 3. Networking & Ingress
- **Ingress Controller (NGINX):**  
  Manages external access to services inside the cluster (like a reverse proxy).  
  It routes traffic from the outside world to the right internal service.

- **Service:**  
  A stable endpoint that exposes a set of Pods. It ensures load balancing and discovery.

---

### 💾 4. Storage & Configuration
- **ConfigMap:**  
  Stores configuration data (non-sensitive) used by Pods.

- **Secret:**  
  Holds **sensitive data** (passwords, tokens, API keys) securely.

- **Persistent Volume (PV):**  
  Provides storage that **persists even if Pods restart**.

---

### 🧍‍♂️ 5. Clients (Users)
- Developers, admins, or automation tools interact using:
  - `kubectl` (CLI)
  - Kubernetes Dashboard (Web UI)
  - Kubernetes API directly (RESTful calls)

---

## 🎯 Key Highlights

✅ Fully declarative and self-healing architecture  
✅ Master–Worker separation for high scalability  
✅ Layered design for modular control  
✅ Extensible and cloud-agnostic  
✅ Auto-scaling, rolling updates, and zero downtime deployments  

---

## 🧩 Summary Flow
> **Clients → Ingress → Services → Pods → Containers → Config & Storage**  
> Managed by **Control Plane → API Server → etcd → Controller Manager → Scheduler**

---

## 📚 Reference Topics for Next Day
🔹 Day-3 → Kubernetes Components in Action (Deep Dive into Pods, Deployments, and Services)  
🔹 Day-4 → Networking & Service Discovery  

---

<p align="center">
  💙 Designed & Maintained by <strong>Tech With Diwana</strong>  
  <br>
  <i>Edited for Education — Kubernetes Zero to Hero Series</i>
</p>
