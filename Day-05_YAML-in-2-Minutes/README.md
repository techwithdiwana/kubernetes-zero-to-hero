
<h1 align="center">☸️ Kubernetes Zero to Hero — Day 5</h1>
<h3 align="center">⚡ YAML in 2 Minutes | Understand YAML Before Pods 🚀</h3>

<p align="center">
  <img src="https://img.shields.io/badge/🎥%20Watch%20on%20YouTube-red?logo=youtube&logoColor=white" />
  <img src="https://img.shields.io/badge/⏱️_Duration-2_Minutes-blue" />
  <img src="https://img.shields.io/badge/☸️_Kubernetes-v1.30-brightgreen" />
  <img src="https://img.shields.io/badge/📚_Series-Zero_to_Hero-orange" />
  <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
</p>

---

<p align="center">
  <img src="https://github.com/devopswithdiwana/assets/blob/main/banners/day5-yaml-banner.png" alt="YAML in 2 Minutes Banner" width="90%"/>
</p>

---

## 🎬 **About This Lesson**

Welcome to **Day-5** of the *Kubernetes Zero to Hero* series by **Tech With Diwana** 💙  

In just **2 minutes**, you’ll master the **foundation of every Kubernetes configuration — YAML**.  
Before you deploy your first Pod, it’s critical to understand how YAML structures the data that Kubernetes reads.

---

## 🧠 **What You’ll Learn**

✅ What YAML actually is and why Kubernetes uses it  
✅ The 4 key sections: `apiVersion`, `kind`, `metadata`, `spec`  
✅ YAML syntax — mappings (`:`) and lists (`-`)  
✅ Indentation & formatting rules  
✅ Complete Pod YAML explained line-by-line  

---

## ⚙️ **Sample Pod YAML**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: web
spec:
  containers:
    - name: nginx
      image: nginx:1.27
      ports:
        - containerPort: 80
```

---

## 🧩 **YAML Building Blocks**

| Type | Symbol | Example |
|------|---------|----------|
| Mapping | `:` | `name: nginx` |
| Sequence (List) | `-` | `- containerPort: 80` |
| Nested Structure | combo | `containers: - name: nginx` |

---

## ⚡ **Golden Rules of YAML**

1️⃣ Use **2 spaces** for indentation — never tabs  
2️⃣ Each key ends with a colon (`:`)  
3️⃣ Lists begin with a dash (`-`)  
4️⃣ Indentation defines structure, not order  
5️⃣ YAML is **case-sensitive** (`Name` ≠ `name`)  

---

## 🧩 **YAML Key Sections Explained**

| Section | Description | Example |
|----------|--------------|----------|
| `apiVersion` | API group and version used by Kubernetes | `v1` or `apps/v1` |
| `kind` | Defines object type (Pod, Service, Deployment) | `Pod` |
| `metadata` | Identity info (name, labels, namespace) | `name: nginx-pod` |
| `spec` | Blueprint of object’s behavior | containers, images, ports |

---

## 🔗 **Next Episode**
▶ **[Day-6 — Create Your First Pod in Kubernetes ☸️](#)**  
(*Coming soon*)  

---

## 🧭 **Connect with Tech With Diwana**

<p align="center">
  <a href="https://youtube.com/@TechWithDiwana"><img src="https://img.shields.io/badge/YouTube-Subscribe-red?logo=youtube&logoColor=white" /></a>
  <a href="https://linkedin.com/in/"><img src="https://img.shields.io/badge/LinkedIn-Follow-blue?logo=linkedin" /></a>
  <a href="https://instagram.com/"><img src="https://img.shields.io/badge/Instagram-Follow-purple?logo=instagram" /></a>
  <a href="https://twitter.com/"><img src="https://img.shields.io/badge/X(Twitter)-Follow-black?logo=x" /></a>
</p>

---

## 🧱 **Repository Structure**

```
📂 kubernetes-zero-to-hero/
 ├── Day-01_Introduction/
 ├── Day-02_K8s-Architecture/
 ├── Day-03_K8s-Components/
 ├── Day-04_Setup-Cluster/
 ├── ✅ Day-05_YAML-in-2-Minutes/
 │    ├── README.md
 │    └── pod-sample.yaml
 └── Day-06_Create-First-Pod/
```

---

## 💬 **Support the Series**

If this helped you, ⭐ **star the repo** and share it with fellow DevOps learners!  
Your support powers the **Tech With Diwana – Kubernetes Zero to Hero** journey 🚀  

---

<p align="center">
  <img src="https://img.shields.io/badge/Day 5 of 25-Progress ▰▰▰▰▰▱▱▱-blue" />
</p>

<p align="center">
  <b>Learn • Build • Automate • Deploy — with Tech With Diwana 💙</b>
</p>
