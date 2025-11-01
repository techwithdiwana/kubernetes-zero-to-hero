# 🚀 Kubernetes Zero to Hero – Day 8: Namespaces, Labels, ConfigMaps & Secrets

<p align="center">
  <img src="https://img.shields.io/badge/Kubernetes-Day%208-blue?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Level-Beginner-success?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Project-Reproducible-lightgrey?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Series-Tech With Diwana-red?style=for-the-badge"/>
</p>

---

## 🎯 What You’ll Learn
- 🔹 Understand **Namespaces** – isolation of environments or teams inside one cluster  
- 🔹 Use **Labels & Selectors** – connect Deployments and Services  
- 🔹 Create **ConfigMaps** – inject non-secret configurations into pods  
- 🔹 Manage **Secrets** – store sensitive information securely  
- 🔹 Learn **Dry-Run → YAML → Apply → Verify** workflow  
- 🔹 Combine everything from **Day 1 → Day 8** into one working application  
- 🔹 Fix real-world issues like missing endpoints or stale configuration

---

## ⚙️ Prerequisites
- A running Kubernetes cluster (`kind`, `minikube`, or `kubeadm`)  
- `kubectl` CLI installed  
- Internet connection to pull the `nginx:1.27` image  

---

## 💡 Dry-Run Limitation Recap
Dry-run YAML is a **starting point**, not a finished manifest:

| Limitation | What to Add Manually |
|-------------|---------------------|
| Missing `data` or HTML in ConfigMap | Add `data.index.html` block |
| No custom labels or selectors | Add `app`, `tier`, `env` labels; match them |
| No `volumes` or `volumeMounts` | Add ConfigMap/Secret mounts |
| Single replica only | Increase `replicas` if needed |
| No probes/resources | Add later for production |

> **Rule:** Generate → Audit → Edit → Apply ✅

---

## 🧱 Step-by-Step Demo
1. **Namespace**
   ```bash
   kubectl create namespace day8-lab --dry-run=client -o yaml > ns.yaml
   kubectl apply -f ns.yaml
   ```

2. **ConfigMap**
   - Use ConfigMap to serve HTML via Nginx  
   ```bash
   kubectl create configmap app-config -n day8-lab --dry-run=client -o yaml > cm.yaml
   ```
   Edit and add HTML under `data:` block, then apply.

3. **Deployment**
   - Add labels, selector, and ConfigMap mount  
   ```bash
   kubectl create deployment web --image=nginx:1.27 -n day8-lab --dry-run=client -o yaml > deploy.yaml
   ```
   Edit: add replicas=2, volumes, volumeMounts, and labels. Then:
   ```bash
   kubectl apply -f deploy.yaml
   ```

4. **Service**
   - Expose deployment and ensure selector matches labels
   ```bash
   kubectl expose deployment web --name=web --port=80 --target-port=80 --type=NodePort -n day8-lab --dry-run=client -o yaml > svc.yaml
   kubectl apply -f svc.yaml
   kubectl -n day8-lab port-forward svc/web 8080:80
   ```

5. **Secrets**
   ```bash
   kubectl create secret generic app-secrets --from-literal=DB_USER=admin --from-literal=DB_PASS='S3cur3P@ss!' -n day8-lab --dry-run=client -o yaml > secret.yaml
   kubectl apply -f secret.yaml
   ```

6. **Verify**
   Visit `http://localhost:8080` to see:
   ```
   Payments App v1.0
   Environment: production
   Namespace: day8-lab
   Served directly from a ConfigMap mounted into Nginx.
   ```

---

## 🧩 Recap
| Day | Concept | Used Here |
|:--:|:--|:--|
| 1 | Pod | Nginx pod |
| 2 | Deployment | Controls replicas |
| 3 | ReplicaSet | Maintains state |
| 4 | Service | Connects pods |
| 5 | Ports & Probes | Add later |
| 6 | Volumes | Mounts ConfigMap |
| 7 | Resources | Add limits later |
| 8 | Namespace, Labels, ConfigMap, Secret | Today’s focus |

---

## 🔒 Interview Scenarios
| Question | Answer |
|-----------|--------|
| Service has 0 endpoints | Label mismatch between pods & selector |
| ConfigMap change not applied | Restart pods to reload |
| Teams mixing workloads | Separate namespaces |
| Password safety | Use Secret instead of ConfigMap |
| Pod knows its namespace | Use Downward API |

---

## 🧹 Cleanup
```bash
kubectl delete ns day8-lab --wait=true
```

---

## 🎥 Next Episode
**Day 9: Services & Ingress — Routing Traffic into Kubernetes**

<p align="center">
  💙 Powered by <a href="https://youtube.com/@TechWithDiwana">Tech With Diwana</a> 🚀
</p>
