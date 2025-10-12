# ⚡ GKE Autopilot Quickstart (Optional)

> Managed control plane; pay only for pod resources. Perfect for short demos.

```bash
gcloud services enable container.googleapis.com
gcloud container clusters create-auto techwithdiwana-cluster --region=us-central1
gcloud container clusters get-credentials techwithdiwana-cluster --region=us-central1
kubectl get nodes
# Clean up
gcloud container clusters delete techwithdiwana-cluster --region=us-central1
```
