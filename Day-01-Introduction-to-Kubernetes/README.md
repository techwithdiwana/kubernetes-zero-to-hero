# 🚀 Day 1: Introduction to Kubernetes

<p align="center">
  <a href="https://youtube.com/@techwithdiwana"><img alt="YouTube - Tech With Diwana" src="https://img.shields.io/badge/YouTube-Tech%20With%20Diwana-red"></a>
  <img alt="Course Day" src="https://img.shields.io/badge/Day-01-blue">
  <img alt="Level" src="https://img.shields.io/badge/Level-Beginner-success">
  <img alt="Topic" src="https://img.shields.io/badge/Topic-Kubernetes%20Intro-informational">
  <img alt="License" src="https://img.shields.io/badge/License-MIT-lightgrey">
</p>

Welcome to **Day 1** of the **Kubernetes Zero to Hero** series — powered by **Tech With Diwana** 🎥  
Today we focus on the **idea of Kubernetes**, **why it exists**, and **what problems it solves**. *(Architecture is covered in Day-2.)*

---

## 🎯 Learning Objectives
- Understand what Kubernetes is  
- Know why organizations use Kubernetes  
- Learn the key features that make Kubernetes powerful  
- Compare Docker vs Kubernetes in simple terms  
- Create your first local cluster using Kind  
- Explore basic `kubectl` commands  

---

## 🧠 What is Kubernetes?
- **Kubernetes (K8s)** is an **open-source container orchestration platform**.  
- It helps you **deploy, scale, and manage** containerized apps automatically.  
- Originally developed by **Google**, now maintained by **CNCF**.  
- Think of it as an **“Operating System for containerized apps.”**

---

## ⚙️ Why Do We Need Kubernetes?
- Containers can crash → **Kubernetes auto-heals** them.  
- Need to handle traffic spikes → **auto-scaling** with replicas.  
- Safe releases → **rolling updates & rollbacks**.  
- Built-in **service discovery, networking, and storage**.  
- **Consistency** across dev, staging, and production.

---

## 🌍 Real-World Examples
- **Streaming / Media** platforms running hundreds of microservices.  
- **E-commerce** apps (frontend + backend + database) managed in one cluster.  
- **Startups to Enterprises** use K8s for speed, reliability, and scale.

---

## 💪 Key Features of Kubernetes
- **Self-Healing** (restart failed containers)  
- **Auto-Scaling** (HPA/VPA)  
- **Load Balancing** (Services)  
- **Rolling Updates** (zero-downtime)  
- **Storage Orchestration** (PV/PVC/StorageClass)  
- **Service Discovery** (built-in DNS)  
- **Config & Secrets Management** (ConfigMap/Secret)

---

## 🧩 Kubernetes vs Docker (Simple View)
| Feature | Docker | Kubernetes |
|---|---|---|
| Purpose | Run a single container | Run containers **at scale** |
| Scaling | Manual | **Automatic** |
| Load Balancing | Not built-in | **Built-in via Services** |
| Self-Healing | No | **Yes** |
| Multi-Host | Limited | **Yes** |
| Declarative | Partial | **Fully declarative (YAML)** |

> 💡 **In short:** Docker = “run a container”, Kubernetes = “run containers reliably at scale.”

---

## 🧪 Hands-On Lab: Create Your First Cluster with Kind
### Prerequisites
- Docker Desktop/Engine  
- `kubectl` installed  
- `kind` (Kubernetes in Docker) installed  

### Commands
```bash
# Create a new Kubernetes cluster
kind create cluster --name k8s-lab

# Verify the cluster
kubectl get nodes
kubectl cluster-info

# Check all running pods in all namespaces
kubectl get pods -A
```

✅ **Congrats!** You’ve created your first local Kubernetes cluster 🎉

---

## 🧠 Common Commands
| Command | Description |
|---|---|
| `kubectl get nodes` | Show cluster nodes |
| `kubectl get pods -A` | List pods in all namespaces |
| `kubectl describe node <node>` | Node details |
| `kubectl version` | Client & server version |
| `kind get clusters` | List Kind clusters |
| `kind delete cluster --name k8s-lab` | Delete the cluster |

---

## 🧩 Verify Your Learning
- Define **what Kubernetes is**  
- Explain **why it’s used**  
- **Create** & **verify** a Kind cluster  
- Use basic **kubectl** commands

---

## 📹 YouTube
🎥 Watch the lesson: **Tech With Diwana** → https://youtube.com/@techwithdiwana

---

## 📚 Helpful Resources
- Official Docs → https://kubernetes.io/docs/home/  
- Kind → https://kind.sigs.k8s.io/  
- kubectl Cheat Sheet → https://kubernetes.io/docs/reference/kubectl/cheatsheet/

---

## 🏁 Homework
- Install `kubectl` + `kind`  
- Create a cluster named `k8s-demo`  
- Run: `kubectl get nodes`, `kubectl get pods -A`  
- Delete the cluster:
```bash
kind delete cluster --name k8s-demo
```

---

## 🏆 Next Lesson
**Day-2 — Kubernetes Architecture Deep Dive** → `../Day-02-Kubernetes-Architecture/README.md`
